# DuoSpend — Decisions Log

Format :
```
### [DATE] — [TITRE]
**Contexte** : pourquoi la question se posait
**Décision** : ce qui a été choisi
**Alternatives rejetées** : options écartées et pourquoi
```

---

### 2025-02-10 — SwiftData comme couche de persistance

**Contexte** : Choix de la solution de stockage local avec sync iCloud possible.
**Décision** : SwiftData. Intégration native SwiftUI, sync iCloud automatique via CloudKit, moins de boilerplate que Core Data, modern Swift API.
**Alternatives rejetées** :
- Core Data → verbeux, intégration SwiftUI moins naturelle
- Realm → dépendance tierce (contraire au principe zéro dépendance)
- SQLite/GRDB → trop bas niveau, pas de sync iCloud gratuite

---

### 2025-02-10 — MVVM avec Observation framework

**Contexte** : Choix d'architecture.
**Décision** : MVVM avec `@Observable` (iOS 17+). Simple, adapté à SwiftUI, pas de boilerplate `ObservableObject` / `@Published`.
**Alternatives rejetées** :
- TCA → trop complexe pour la taille du projet + dépendance tierce
- MV (sans ViewModel) → insuffisant pour la logique de calcul de balance
- VIPER → overkill pour une app indie solo

---

### 2025-02-10 — Decimal pour les montants financiers

**Contexte** : Quel type pour stocker les montants d'argent.
**Décision** : `Decimal` (Foundation). Précision exacte, pas d'erreur d'arrondi.
**Alternatives rejetées** :
- `Double` → 0.1 + 0.2 ≠ 0.3, inacceptable pour de l'argent
- `Int` (centimes) → fonctionnel mais moins lisible, conversion nécessaire partout

---

### 2025-02-10 — Zéro dépendance tierce

**Contexte** : Utiliser ou non des librairies externes (Charts, Lottie, etc.).
**Décision** : Aucune. Apple frameworks uniquement.
**Raisons** : pas de maintenance deps, pas de breaking changes, app plus légère, apprentissage Swift natif.

---

### 2025-02-10 — MVP tout gratuit, paywall en v2

**Contexte** : Implémenter le freemium dès le départ ?
**Décision** : Non. Tout gratuit dans le MVP. StoreKit 2 + paywall ajoutés en v2 après validation de l'UX.
**Raison** : Se concentrer sur la valeur produit, pas la monétisation. Pas de friction utilisateur pendant la phase de validation.

---

### 2025-02-10 — Euro uniquement au MVP

**Contexte** : Supporter plusieurs devises ?
**Décision** : Non. Euro (€) uniquement. Multi-devises en v3 éventuel.
**Raison** : Cible initiale = France. Ajouter le multi-devises complexifie les calculs (taux de change) et l'UX pour un gain marginal au lancement.

---

### 2025-02-10 — Maximum 2 partenaires par projet (jamais plus)

**Contexte** : Permettre 3+ personnes ?
**Décision** : Non, jamais. DuoSpend est pour les **couples**. 2 partenaires max, c'est le concept.
**Raison** : 3+ personnes = Splitwise/Tricount. La contrainte à 2 simplifie radicalement l'UX, le calcul de balance, et le positionnement marketing.

---

### 2025-02-11 — Budget obligatoire par projet (pas optionnel)

**Contexte** : Le budget était optionnel à la création du projet.
**Décision** : Le budget devient **obligatoire**. `Project.budget` passe de `Decimal?` à `Decimal`.
**Raison** : Le budget par projet est le cœur du concept DuoSpend ("budget projets pour couples"). Sans budget, l'app n'est qu'un tracker de dépenses classique. La barre de progression budget/dépensé est le visuel clé qui différencie l'app.

---

### 2025-02-11 — Monétisation : 1 projet gratuit + achat unique 3,99 €

**Contexte** : Comment monétiser l'app ?
**Décision** : Freemium avec 1 projet gratuit. Achat unique (non-consommable) à 3,99 € pour débloquer les projets illimités à vie. StoreKit 2, product ID `com.duospend.unlimitedprojects`.
**Raison** : Pas d'abonnement (trop agressif pour une app utilitaire). Pas de pubs (ruine l'UX). 3,99 € est le sweet spot App Store FR pour ce type d'app. 1 projet gratuit permet de tester vraiment l'app avant de payer. Conversion estimée : 3-5% des users actifs.
