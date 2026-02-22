# DuoSpend 💰

> App iOS de gestion de budget par projet pour couples.
> Une question, une réponse : **"Qui doit combien à qui ?"**

---

## Aperçu

DuoSpend permet à deux personnes de suivre leurs dépenses communes sur des projets partagés (mariage, voyage, colocation…). Chacun enregistre ce qu'il paie, l'app calcule automatiquement le solde net et indique qui rembourse qui.

**Principe :** pas d'inscription, pas de cloud obligatoire, pas de pub. Tout fonctionne hors ligne.

---

## Stack

| | |
|---|---|
| Langage | Swift 6 (strict concurrency) |
| UI | SwiftUI — iOS 17+ |
| Persistance | SwiftData (`@Model`) |
| Sync | iCloud automatique via SwiftData |
| Architecture | MVVM + Observation framework |
| Tests | Swift Testing + XCTest (UI) |
| Dépendances | Aucune — Apple frameworks uniquement |

---

## Fonctionnalités MVP

- **Projets** — créer un projet avec emoji, noms des partenaires, budget cible optionnel
- **Dépenses** — ajouter titre, montant, payeur, répartition (50/50 ou custom)
- **Balance** — calcul en temps réel du solde net ("Thomas doit 70 € à Marie")
- **Dark mode** — supporté nativement via couleurs système
- **iCloud** — sync transparente si le compte Apple est connecté

---

## Structure du projet

```
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

```
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

- **Views** — affichage uniquement, zéro logique métier
- **ViewModels** — `@Observable`, état de présentation, CRUD via `ModelContext`
- **Services** — fonctions pures, testables sans SwiftUI ni SwiftData
- **Models** — `@Model` SwiftData, données pures + relations `@Relationship`

---

## Logique de balance

```
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
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build

# Tests
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test

# Clean
xcodebuild -scheme DuoSpend clean
```

---

## Roadmap

| Feature | Version |
|---|---|
| MVP (balance, projets, dépenses) | v1 — en cours |
| Templates projets | v2 |
| Export PDF | v2 |
| Paywall one-time (6,99 € StoreKit 2) | v2 |
| Widgets iOS | v2 |
| Graphiques Charts | v2 |
| Multi-devises | v3 |
| Plus de 2 partenaires | ❌ hors scope |

---

## Principes

1. **Local-first** — fonctionne hors ligne, iCloud = bonus
2. **Zéro dépendance** — Apple frameworks uniquement
3. **Privacy by design** — aucune donnée ne quitte l'appareil (sauf iCloud du user)
4. **Simple > Complet** — moins de features, mieux exécutées
5. **Éco-conception** — code efficient, pas de superflu

---

## Conventions

- Commits en français : `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `style:`
- Montants en `Decimal`, jamais `Double`
- Jamais de force unwrap `!` hors `Preview Content/`
- `@Observable` classes (Observation framework), jamais `ObservableObject`
- Voir [`CLAUDE.md`](CLAUDE.md) pour les conventions complètes
