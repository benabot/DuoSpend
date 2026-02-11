# DuoSpend — Spécification MVP

## Vision

DuoSpend aide les couples à gérer leurs dépenses communes **par projet** sans se prendre la tête. L'app répond à une seule question : **"Qui doit combien à qui ?"**

---

## Personas

### Marie & Thomas — 30 ans, préparent leur mariage
Ils avancent chacun des frais (traiteur, salle, DJ, déco…). Thomas paie souvent par carte, Marie par virement. Ils veulent savoir à tout moment qui a payé quoi et quel est le solde net entre eux.

### Léa & Hugo — 27 ans, partent en roadtrip
Hugo paie l'essence, Léa les restos. Certaines dépenses sont 50/50, d'autres non (Hugo paie seul son équipement photo). Ils veulent un bilan clair en fin de voyage.

---

## Parcours utilisateur

### Première ouverture
1. Écran d'accueil vide : illustration + "Créez votre premier projet"
2. Tap → formulaire de création projet
3. Projet créé → arrivée sur le détail, prêt à ajouter des dépenses

### Usage quotidien
1. Ouvrir l'app → voir la liste des projets en cours
2. Tap sur un projet → voir le solde ("Thomas doit 70€ à Marie") et la liste des dépenses
3. Tap "+" → ajouter une dépense (titre, montant, qui paie, répartition)
4. Le solde se met à jour instantanément

### Fin de projet
1. Consulter le solde final
2. Le débiteur rembourse le créditeur (en dehors de l'app)
3. Archiver ou supprimer le projet

---

## Écrans

### 1. ProjectListView — Liste des projets

**État vide :**
- Illustration simple (ou emoji géant 💰)
- Texte : "Créez votre premier projet de couple"
- Bouton CTA principal

**Avec projets :**
- Liste de cards scrollable verticalement
- Chaque card affiche :
  - Emoji + nom du projet
  - Montant total dépensé
  - Indicateur balance rapide (vert = équilibre, rouge/bleu = déséquilibre)
- Swipe left → supprimer (avec alert confirmation)
- Bouton "+" en toolbar pour créer un nouveau projet

**Navigation :** tap sur card → `ProjectDetailView`

---

### 2. CreateProjectView — Créer un projet

Présenté en `.sheet` depuis la liste.

**Champs :**
| Champ | Type | Requis | Contrainte |
|---|---|---|---|
| Nom du projet | TextField | ✅ | max 50 chars |
| Emoji | Picker (grille d'emojis courants) | ✅ | défaut : 💰 |
| Partenaire 1 | TextField | ✅ | max 30 chars |
| Partenaire 2 | TextField | ✅ | max 30 chars |
| Budget cible | TextField numérique | ❌ | Decimal, clavier .decimalPad |

**Bouton "Créer"** : actif quand nom + 2 noms partenaires remplis.
**Post-création** : dismiss sheet → navigation automatique vers le projet.

---

### 3. ProjectDetailView — Détail d'un projet

**Structure de haut en bas :**

**Header :**
- Emoji + nom du projet
- Barre de progression budget si budget cible défini ("1 240€ / 5 000€")
- Si pas de budget cible : juste le total dépensé

**BalanceBanner (composant) :**
- Encart arrondi, coloré
- Affiche : "Thomas doit 70,00 € à Marie" (en gros)
- Ou : "Vous êtes à l'équilibre ✅" (fond vert)
- Couleur dynamique : rouge/bleu si déséquilibre, vert si équilibre

**Section dépenses :**
- Titre "Dépenses" avec compteur (12 dépenses)
- Liste chronologique inversée (plus récentes en haut)
- Chaque ligne (ExpenseRow) :
  - Pastille couleur du payeur (couleur partenaire)
  - Titre de la dépense
  - Montant
  - Nom du payeur + date
  - Indicateur répartition si custom (ex: "70/30")
- État vide : "Aucune dépense — tapez + pour commencer"

**FAB "+"** : ouvre `AddExpenseView` en sheet

**Toolbar :** titre du projet, bouton edit (modifier nom/budget/noms)

---

### 4. AddExpenseView — Ajouter une dépense

Présenté en `.sheet` depuis le détail projet.

**Champs :**
| Champ | Type | Requis | Détail |
|---|---|---|---|
| Titre | TextField | ✅ | max 100 chars, placeholder "Restaurant, hôtel..." |
| Montant | TextField | ✅ | .decimalPad, Decimal, placeholder "0,00 €" |
| Payé par | Picker segmented | ✅ | [Partenaire 1 / Partenaire 2], défaut P1 |
| Répartition | Picker segmented | ✅ | [50/50 / Custom], défaut 50/50 |
| Part P1 (si custom) | Slider ou TextField | conditionnel | pourcentage, ex: 70% |
| Part P2 (si custom) | Auto-calculé | conditionnel | 100% - part_P1 |
| Date | DatePicker | ✅ | défaut aujourd'hui |

**Bouton "Ajouter"** : actif quand titre + montant > 0 remplis.
**Post-ajout** : dismiss sheet, retour au détail, balance recalculée.

---

### 5. Composants réutilisables

**ProjectCard** — utilisé dans `ProjectListView`
```
┌─────────────────────────────┐
│ 💒  Mariage                 │
│ 3 240,00 € dépensés        │
│ 🔴 Thomas doit 70€ à Marie │
└─────────────────────────────┘
```

**ExpenseRow** — utilisé dans `ProjectDetailView`
```
┌─────────────────────────────┐
│ 🔵 Restaurant Le Zinc       │
│    80,50 € — Marie · 15 jan │
└─────────────────────────────┘
```

**BalanceBanner** — utilisé dans `ProjectDetailView`
```
┌─────────────────────────────────┐
│  Thomas doit 70,00 € à Marie   │
│  ████████████░░░░  (ratio vis.) │
└─────────────────────────────────┘
```

---

## Logique métier

### Algorithme de calcul de balance

**Entrée** : liste d'`Expense` d'un `Project`
**Sortie** : `Balance` (qui doit combien à qui)

```
balance_nette = 0

Pour chaque dépense :
    Si splitRatio == .equal :
        part_chacun = amount / 2
    Si splitRatio == .custom(p1Share, p2Share) :
        total_parts = p1Share + p2Share
        part_P1 = amount × (p1Share / total_parts)
        part_P2 = amount × (p2Share / total_parts)

    Si payé par P1 :
        balance_nette += part_P2   // P2 doit cette part à P1
    Si payé par P2 :
        balance_nette -= part_P1   // P1 doit cette part à P2

Résultat :
    balance_nette > 0 → P2 doit balance_nette à P1
    balance_nette < 0 → P1 doit |balance_nette| à P2
    balance_nette == 0 → équilibre
```

### Scénarios de test

**Scénario 1 — Tout 50/50 :**
- Restaurant 80€, payé par Marie → Thomas doit 40€
- Essence 60€, payé par Thomas → Marie doit 30€
- **Résultat : Thomas doit 10€ à Marie**

**Scénario 2 — Mix 50/50 et custom :**
- Restaurant 80€, payé Marie, 50/50 → Thomas doit 40€
- Essence 60€, payé Thomas, 50/50 → Marie doit 30€
- Hôtel 200€, payé Marie, 70/30 → Thomas doit 60€
- **Résultat : Thomas doit 70€ à Marie** (40+60-30)

**Scénario 3 — Équilibre parfait :**
- Dîner 100€, payé Marie, 50/50 → Thomas doit 50€
- Billets 100€, payé Thomas, 50/50 → Marie doit 50€
- **Résultat : Équilibre ✅**

**Scénario 4 — Une seule dépense :**
- Location voiture 300€, payé Thomas, 60/40 → Marie doit 120€
- **Résultat : Marie doit 120€ à Thomas**

---

## Design guidelines

### Couleurs
- Partenaire 1 : bleu (`.blue`) — utilisé pour pastilles, graphiques
- Partenaire 2 : rose/corail (`.pink` ou custom) — idem
- Balance positive (P2 doit) : fond bleuté léger
- Balance négative (P1 doit) : fond rosé léger
- Équilibre : fond vert léger
- Dark mode : supporté dès le départ via couleurs système + assets

### Typographie
- SF Pro (system font)
- Montants en `.title` ou `.largeTitle` pour la balance
- Corps de texte en `.body`

### Formatage des montants
- Toujours via `Decimal` + `NumberFormatter` / `formatted(.currency(code: "EUR"))`
- Respecter `Locale.current` pour le format (1 234,56 € en fr)
- Affichage uniforme : toujours 2 décimales

### Interactions
- Haptic feedback sur les actions principales (ajout dépense, création projet)
- Swipe actions sur les listes (supprimer)
- Sheet pour les formulaires (create project, add expense)
- Transitions NavigationStack standard

---

## Hors périmètre MVP

Ces fonctionnalités sont volontairement exclues du MVP pour livrer vite :

| Feature | Raison d'exclusion | Cible |
|---|---|---|
| Sync entre 2 appareils | CloudKit sharing complexe | v2 |
| Templates projets | Nice-to-have, pas essentiel | v2 |
| Export PDF | Pas critique pour valider le concept | v2 |
| Catégories + icônes | Complexité UX supplémentaire | v2 |
| Widgets iOS | WidgetKit = module séparé | v2 |
| Graphiques Charts | Polish, pas core | v2 |
| Paywall StoreKit 2 | Valider l'UX d'abord | v2 |
| Onboarding | L'app doit être assez simple pour s'en passer | v2 |
| Multi-devises | Niche trop petite au lancement | v3 |
| Plus de 2 partenaires | Change le concept (→ Splitwise) | ❌ jamais |
