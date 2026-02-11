---
name: duospend-ios
description: Aide au développement de DuoSpend, app iOS Swift/SwiftUI de gestion de budget par projet pour couples. Utiliser ce skill quand l'utilisateur (1) mentionne DuoSpend, budget couples, ou le chemin /Users/benoitabot/Sites/DuoSpend, (2) travaille sur du code Swift/SwiftUI pour cette app, (3) discute architecture, modèles de données ou fonctionnalités de DuoSpend, (4) prépare des tâches pour Claude Code ou Codex sur ce projet.
---

# DuoSpend — Budget projets pour couples

App iOS native pour gérer les dépenses d'un couple **par projet** (mariage, voyage, travaux, bébé). Chacun entre ses dépenses, l'app calcule qui doit combien à qui.

**Dépôt** : `/Users/benoitabot/Sites/DuoSpend`

---

## Fiche produit

### Pitch
Les couples qui préparent un projet commun (mariage, déménagement, roadtrip, naissance) avancent chacun des frais. DuoSpend répond à une seule question : **"Qui doit combien à qui ?"** — sans prise de tête, sans compte joint, sans inscription.

### Ce que DuoSpend n'est PAS
- ❌ Pas un budget mensuel (≠ Bankin, YNAB, Linxo)
- ❌ Pas un split entre amis (≠ Splitwise, Tricount)
- ❌ Pas une connexion bancaire
- ❌ Pas un outil comptable

### Cible
Couples 25-40 ans qui préparent un projet commun et veulent clarifier les finances sans tension.

### Différenciation
- **Par projet** : chaque projet a son propre budget et ses propres dépenses
- **Pour 2 personnes** : UX pensée pour un couple, pas un groupe
- **Local-first** : fonctionne hors ligne, données sur l'appareil + iCloud
- **Achat unique** : pas d'abonnement

---

## Stack technique

- Swift 6 + SwiftUI (iOS 17+)
- SwiftData + CloudKit automatique
- Architecture MVVM (Observation framework)
- Zéro dépendance tierce
- Xcode 16+

---

## Fichiers du projet

**Toujours lire en premier :**
1. `CLAUDE.md` — conventions de code, structure Xcode, modèles de données
2. `docs/TODO.md` — tâches en cours par sprint
3. `docs/MVP.md` — spécification fonctionnelle complète

**Références :**
- `docs/ARCHITECTURE.md` — schéma MVVM, couches, config SwiftData
- `docs/DECISIONS.md` — log des décisions actées avec contexte et alternatives

---

## Workflows

### 1. Implémenter une feature

**Déclencheur** : "Implémente [feature]", "Code [écran]", "Ajoute [composant]"

**Processus :**
1. Lire `CLAUDE.md` → conventions, structure, modèles
2. Lire `docs/MVP.md` → comportement attendu de la feature
3. Vérifier `docs/DECISIONS.md` → contraintes à respecter
4. Coder en MVVM :
   - Model (`@Model` SwiftData) si nouveau modèle
   - View (SwiftUI) pour l'affichage
   - ViewModel (`@Observable`) si logique de présentation
   - Service si logique métier pure
5. Proposer la mise à jour de `docs/TODO.md`

### 2. Préparer un prompt pour Claude Code / Codex

**Déclencheur** : "Prépare un prompt Claude Code", "Tâche pour Codex"

**Processus :**
1. Lire `docs/TODO.md` → prochaine tâche
2. Lire le code existant pertinent
3. Rédiger un prompt autonome :

```markdown
## Contexte
DuoSpend — app iOS SwiftUI/SwiftData.
Lire CLAUDE.md pour les conventions.
[État actuel : quels fichiers existent, ce qui fonctionne déjà]

## Tâche
[Description précise]

## Fichiers à créer/modifier
- `DuoSpend/Views/X.swift` : [ce qu'il doit contenir]
- `DuoSpend/Models/Y.swift` : [modifications]

## Contraintes
- MVVM, @Observable, pas ObservableObject
- SwiftData @Model pour la persistance
- Decimal pour les montants, jamais Double
- Zéro dépendance tierce

## Validation
- [ ] Compile sans warning
- [ ] Preview fonctionne
- [ ] [Critère fonctionnel spécifique]
```

### 3. Review de code

**Déclencheur** : "Review ce code", "Cette approche est-elle bonne ?"

**Répondre avec :**
- ✅ Ce qui est conforme au CLAUDE.md
- ⚠️ Écarts par rapport aux conventions ou à l'architecture
- 🔧 Code corrigé prêt à copier

### 4. Décision technique

**Déclencheur** : "Comment implémenter X ?", "Quelle approche pour Y ?"

**Processus :**
1. Lire `docs/DECISIONS.md` → vérifier si déjà tranché
2. Proposer 2-3 options avec pour/contre
3. Recommander une option
4. Si validé → fournir le bloc markdown pour `docs/DECISIONS.md`

---

## Logique métier clé : calcul de balance

```
Pour chaque dépense d'un projet :
  part_P1 = montant × ratio_P1
  part_P2 = montant × ratio_P2

  Si payé par P1 → P2 doit part_P2 à P1
  Si payé par P2 → P1 doit part_P1 à P2

Balance = Σ(dettes de P2 vers P1) - Σ(dettes de P1 vers P2)

  > 0 → "P2 doit [balance]€ à P1"
  < 0 → "P1 doit [abs]€ à P2"
  = 0 → "Équilibre ✅"
```

**Exemple concret :**
- Restaurant 80€, payé par Marie, 50/50 → Thomas doit 40€
- Essence 60€, payé par Thomas, 50/50 → Marie doit 30€
- Hôtel 200€, payé par Marie, 70/30 → Thomas doit 60€
- **Résultat : Thomas doit 70€ à Marie** (100 - 30)

---

## Écrans MVP

1. **ProjectListView** — accueil, liste de cards projet (état vide si aucun projet)
2. **CreateProjectView** — formulaire : nom, emoji, partenaires, budget optionnel
3. **ProjectDetailView** — header budget + balance + liste dépenses
4. **AddExpenseView** — sheet : titre, montant, payeur, répartition, date
5. **Composants** : ProjectCard, ExpenseRow, BalanceBanner

---

## Périmètre MVP vs Post-MVP

### Dans le MVP
- CRUD projets et dépenses
- Calcul de balance (50/50 + custom)
- Persistance locale SwiftData
- Dark mode
- Formatage montants localisé (€)

### Hors MVP (v2+)
- Sync iCloud entre 2 appareils (CloudKit sharing)
- Templates projets prédéfinis
- Export PDF
- Catégories avec icônes
- Widgets iOS
- Graphiques (Charts framework)
- Paywall StoreKit 2
- Onboarding

---

## Principes

1. **Local-first** — hors ligne d'abord, iCloud = bonus
2. **Zéro dépendance** — Apple frameworks uniquement
3. **Privacy by design** — rien ne quitte l'appareil
4. **Simple > Complet** — moins de features, mieux exécutées
5. **Éco-conception** — code efficient, pas de superflu

---

## Limitations du skill

- Ne pas ajouter de dépendances tierces sans discussion
- Ne pas changer l'architecture MVVM sans justification
- Ne pas implémenter de features hors MVP sans validation
- Ne pas inventer de specs absentes du MVP.md
- Toujours demander confirmation avant d'acter une décision dans DECISIONS.md
