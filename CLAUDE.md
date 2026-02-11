# CLAUDE.md — DuoSpend

> App iOS de gestion de budget par projet pour couples.
> Chacun entre ses dépenses, l'app calcule qui doit combien à qui.

**Chemin racine** : `/Users/benoitabot/Sites/DuoSpend`

---

## Stack technique

| Élément | Choix |
|---|---|
| Langage | Swift 6 (strict concurrency) |
| UI | SwiftUI, target iOS 17+ |
| Persistance | SwiftData (`@Model`) |
| Sync | CloudKit automatique via SwiftData |
| Architecture | MVVM (Observation framework) |
| IDE | Xcode 16+ |
| Dépendances | Aucune. Apple frameworks uniquement |
| Tests | Swift Testing + XCTest pour UI |

---

## Structure cible du projet Xcode

```
DuoSpend/
├── CLAUDE.md
├── SKILLS.md
├── docs/
│   ├── MVP.md
│   ├── ARCHITECTURE.md
│   ├── DECISIONS.md
│   └── TODO.md
├── DuoSpend.xcodeproj
├── DuoSpend/
│   ├── App/
│   │   └── DuoSpendApp.swift        # @main, ModelContainer config
│   ├── Models/
│   │   ├── Project.swift             # @Model — projet de couple
│   │   ├── Expense.swift             # @Model — dépense
│   │   ├── PartnerRole.swift         # enum partner1/partner2
│   │   └── SplitRatio.swift          # enum equal/custom
│   ├── Views/
│   │   ├── ProjectListView.swift     # Accueil : liste des projets
│   │   ├── CreateProjectView.swift   # Formulaire nouveau projet
│   │   ├── ProjectDetailView.swift   # Détail : dépenses + balance
│   │   ├── AddExpenseView.swift      # Sheet ajout dépense
│   │   └── Components/
│   │       ├── ProjectCard.swift     # Card projet dans la liste
│   │       ├── ExpenseRow.swift      # Ligne dépense
│   │       └── BalanceBanner.swift   # Encart "A doit X€ à B"
│   ├── ViewModels/
│   │   └── ProjectDetailViewModel.swift
│   ├── Services/
│   │   └── BalanceCalculator.swift   # Logique pure de calcul
│   ├── Extensions/
│   │   └── Decimal+Currency.swift    # Formatage €
│   ├── Resources/
│   │   └── Assets.xcassets
│   └── Preview Content/
│       └── SampleData.swift          # Données de preview
├── DuoSpendTests/
│   └── BalanceCalculatorTests.swift
└── DuoSpendUITests/
```

---

## Modèles de données

```swift
// MARK: - Project

@Model
class Project {
    var name: String                    // "Mariage", "Roadtrip Espagne"
    var emoji: String                   // "💒", "✈️", "🏠"
    var budget: Decimal?                // Budget cible optionnel
    var partner1Name: String            // "Marie"
    var partner2Name: String            // "Thomas"
    var createdAt: Date

    @Relationship(deleteRule: .cascade)
    var expenses: [Expense] = []
}

// MARK: - Expense

@Model
class Expense {
    var title: String                   // "Restaurant Le Zinc"
    var amount: Decimal                 // 80.50
    var paidBy: PartnerRole             // .partner1
    var splitRatio: SplitRatio          // .equal ou .custom(70, 30)
    var category: String?               // optionnel MVP
    var date: Date

    var project: Project?               // relation inverse
}

// MARK: - Enums

enum PartnerRole: String, Codable {
    case partner1
    case partner2
}

enum SplitRatio: Codable, Equatable {
    case equal                                          // 50/50
    case custom(partner1Share: Decimal, partner2Share: Decimal)  // ex: 70/30
}
```

---

## Conventions de code

### Nommage
- Types → `PascalCase` : `ProjectDetailView`, `BalanceCalculator`
- Propriétés, méthodes → `camelCase` : `totalSpent`, `calculateBalance()`
- Fichiers → même nom que le type principal
- Vues → suffixe `View` : `ProjectListView`
- ViewModels → suffixe `ViewModel` : `ProjectDetailViewModel`
- Composants réutilisables → pas de suffixe `View` : `ProjectCard`, `BalanceBanner`

### SwiftUI
- `@Observable` classes (Observation framework), jamais `ObservableObject`
- `@Bindable` pour les bindings dans les vues
- Extraire toute sous-vue > 40 lignes dans `Components/`
- Aucune vue > 150 lignes
- Ordre des modifiers : layout → apparence → interaction → accessibility

### SwiftData
- `@Model` sur les classes de données uniquement
- Relations explicites avec `@Relationship`
- Zéro logique métier dans les modèles (computed properties simples OK)
- Lectures simples → `@Query` dans les vues
- Opérations CRUD → via `ModelContext` dans les ViewModels

### Architecture MVVM
- **Model** → SwiftData `@Model`, données pures
- **View** → SwiftUI, affichage et interactions utilisateur, zéro logique métier
- **ViewModel** → `@Observable`, logique de présentation, accès `ModelContext`
- **Service** → logique métier pure, testable sans contexte SwiftUI/SwiftData

### Qualité
- `///` doc comment sur chaque fonction et type publics
- Jamais de force unwrap `!` (sauf dans `Preview Content/`)
- Jamais de `print()` → utiliser `os.Logger`
- `guard` early return plutôt que `if` imbriqués
- Erreurs typées : `enum DuoSpendError: LocalizedError`
- Montants toujours en `Decimal`, jamais `Double`

---

## Commandes utiles

```bash
# Ouvrir le projet
open /Users/benoitabot/Sites/DuoSpend/DuoSpend.xcodeproj

# Build
xcodebuild -scheme DuoSpend -destination 'platform=iOS Simulator,name=iPhone 16' build

# Tests
xcodebuild -scheme DuoSpend -destination 'platform=iOS Simulator,name=iPhone 16' test

# Clean
xcodebuild -scheme DuoSpend clean
```

---

## Workflow avec Claude Code / Codex

### Avant de coder
1. Lire `docs/TODO.md` → tâche en cours
2. Lire `docs/MVP.md` → spec fonctionnelle si besoin de contexte
3. Vérifier `docs/DECISIONS.md` → ne pas contredire une décision actée

### Pendant le code
- Un commit = une feature ou un fix
- Messages en français, préfixés : `feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `style:`
- Exemple : `feat: ajout formulaire création projet`

### Après le code
- Cocher la tâche dans `docs/TODO.md`
- Si décision d'archi prise → ajouter dans `docs/DECISIONS.md`

---

## Monétisation (contexte business)

- **MVP** : tout gratuit, pas de paywall
- **v2 Premium** (6,99€ one-time via StoreKit 2) : projets illimités, templates, export PDF
- Zéro abonnement, zéro pub, zéro tracking analytics

---

## Principes directeurs

1. **Local-first** — tout fonctionne hors ligne, iCloud = bonus
2. **Zéro dépendance** — Apple frameworks uniquement
3. **Privacy by design** — aucune donnée ne quitte l'appareil (sauf iCloud du user)
4. **Simple > Complet** — moins de features, mieux exécutées
5. **Éco-conception** — code efficient, images optimisées, pas de superflu
