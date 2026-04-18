# DuoSpend 💰

> App iOS native de budget par projet pour couples.
> Une question, une réponse : **"Qui doit combien à qui ?"**

---

## Statut du projet

DuoSpend est en **Phase 7 — préparation de la soumission App Store** pour la v1.0.0.

Le scope v1.0 est gelé :
- iPhone uniquement ;
- 2 partenaires uniquement ;
- fonctionnement local-first ;
- iCloud / CloudKit **désactivés** en v1.0 ;
- aucune dépendance externe.

---

## Aperçu

DuoSpend permet à un couple de suivre les dépenses d'un projet commun et de savoir en permanence qui doit combien à qui. L'app est organisée **par projet** — mariage, voyage, emménagement, travaux, projet bébé — avec une promesse simple : une balance claire, sans friction ni usine à gaz.

**Principe :** pas de compte, pas de connexion bancaire, pas de sync cloud active en v1.0, pas de pub. Tout fonctionne localement sur l'iPhone.

---

## Stack

| | |
|---|---|
| Langage | Swift 6 (strict concurrency) |
| UI | SwiftUI — iOS 17+ |
| Cible | iPhone uniquement |
| Persistance | SwiftData (`@Model`) |
| Sync | Aucune sync active en v1.0 — iCloud / CloudKit désactivés |
| Architecture | MVVM + Observation framework |
| Tests | Swift Testing + XCTest (UI) |
| Dépendances | Aucune — Apple frameworks uniquement |

---

## Fonctionnalités déjà livrées

- **Projets** — création et édition de projets à deux, avec budget dédié, emoji et partenaires.
- **Dépenses** — ajout, édition, suppression, répartition 50/50 ou personnalisée.
- **Balance** — calcul instantané du solde net avec wording clair : "X doit Y à Z".
- **Onboarding & splash** — parcours de premier lancement stabilisé, sans flash parasite.
- **SettingsView** — thème clair/sombre/système, DuoSpend Pro, export PDF, suppression des données, à propos.
- **Monétisation** — StoreKit 2 en place : 1 projet gratuit, puis achat unique de **6,99 €** pour DuoSpend Pro.
- **DuoSpend Pro** — projets illimités, widgets pour l'écran d'accueil et export PDF.
- **Localisation** — français et anglais via String Catalog.
- **Polish UI** — dark mode, empty states, haptics et composants principaux finalisés.

---

## Structure du projet

```text
DuoSpend/
├── App/
│   └── DuoSpendApp.swift          # @main, ModelContainer
├── Models/
│   ├── Project.swift              # @Model projet
│   ├── Expense.swift              # @Model dépense
│   ├── PartnerRole.swift          # enum partner1/partner2
│   └── SplitRatio.swift           # enum equal/custom
├── Views/
│   ├── ProjectListView.swift      # Accueil — liste des projets
│   ├── CreateProjectView.swift    # Formulaire création projet
│   ├── ProjectDetailView.swift    # Détail : dépenses + balance
│   ├── AddExpenseView.swift       # Sheet ajout dépense
│   └── Components/
│       ├── ProjectCard.swift      # Card dans la liste
│       ├── ExpenseRow.swift       # Ligne dépense
│       └── BalanceBanner.swift    # Encart "A doit X € à B"
├── ViewModels/
│   └── ProjectDetailViewModel.swift
├── Services/
│   └── BalanceCalculator.swift    # Logique pure, testable
└── Extensions/
    └── Decimal+Currency.swift     # Formatage €
```

---

## Architecture

```text
SwiftUI Views
    │  @Query (lectures)
    │  actions utilisateur
    ▼
ViewModels (@Observable)
    │  ModelContext (CRUD)
    │  coordination
    ▼
Services (logique pure)        SwiftData (@Model)
BalanceCalculator  ◀─────────  Project, Expense
```

- **Views** — affichage uniquement, zéro logique métier.
- **ViewModels** — `@Observable`, état de présentation, CRUD via `ModelContext`.
- **Services** — fonctions pures, testables sans SwiftUI ni SwiftData.
- **Models** — `@Model` SwiftData, données pures + relations `@Relationship`.

---

## Logique de balance

```text
Pour chaque dépense :
  part_chacun = amount × ratio (50/50 ou custom)

  Si payé par P1 → balance += part_P2  (P2 doit à P1)
  Si payé par P2 → balance -= part_P1  (P1 doit à P2)

balance > 0 → P2 doit balance à P1
balance < 0 → P1 doit |balance| à P2
balance = 0 → équilibre ✅
```

---

## Commandes

```bash
# Ouvrir dans Xcode
open DuoSpend.xcodeproj

# Build
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build

# Tests
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  test

# Clean
xcodebuild -scheme DuoSpend clean
```

---

## État produit

| Sujet | Statut |
|---|---|
| v1.0 | **Phase 7** — préparation de la soumission App Store |
| Scope v1.0 | local-first, iPhone only, 2 partenaires, pas de sync iCloud / CloudKit active |
| Pricing v1.0 | 1 projet gratuit + achat unique **6,99 €** |
| v1.1 | synchronisation iCloud même compte Apple (prévue, pas active en v1.0) |
| v2.0 | CloudKit Sharing entre 2 comptes Apple |
| Hors scope | groupes, backend tiers, Android |

---

## Principes

1. **Local-first** — fonctionne hors ligne, sans sync iCloud / CloudKit active en v1.0.
2. **Deux partenaires uniquement** — DuoSpend n'est pas conçu pour les groupes.
3. **Privacy by design** — aucune collecte, aucun tracker, aucune publicité.
4. **Simple > complet** — moins de fonctionnalités, mais mieux cadrées.
5. **Zéro dépendance** — frameworks Apple uniquement.

---

## Sources de vérité

Pour les agents, lire dans cet ordre :

1. `/.codex/`
2. `AGENTS.md`
3. `CLAUDE.md`
4. `docs/TODO.md`
5. `docs/DECISIONS.md`
6. `docs/ROADMAP_RELEASE.md`

`README.md` reste un document de présentation humaine du projet.

---

## Conventions

- Commits en français : `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `style:`
- Montants en `Decimal`, jamais `Double`
- Jamais de force unwrap `!` hors `Preview Content/`
- `@Observable` classes (Observation framework), jamais `ObservableObject`
- Voir [`CLAUDE.md`](CLAUDE.md) pour les conventions complètes
