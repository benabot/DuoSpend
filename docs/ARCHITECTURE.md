# DuoSpend — Architecture

## Vue d'ensemble

```
┌───────────────┐     ┌──────────────────────┐     ┌──────────────────┐
│   SwiftUI     │────▶│    ViewModel         │────▶│    Services      │
│   Views       │◀────│    @Observable       │◀────│ BalanceCalculator│
└───────────────┘     └──────────────────────┘     └──────────────────┘
       │                       │
       │ @Query                │ ModelContext
       ▼                       ▼
┌──────────────────────────────────┐
│          SwiftData               │
│   @Model (Project, Expense)      │
│        + iCloud sync             │
└──────────────────────────────────┘
```

## Couches

### Views (SwiftUI)
- Affichage et interactions utilisateur
- Lectures simples via `@Query` (liste de projets, dépenses d'un projet)
- Délèguent les actions utilisateur aux ViewModels
- Aucune logique métier, aucun calcul

### ViewModels (@Observable)
- Logique de présentation (formatage, états d'UI)
- Accès au `ModelContext` pour les opérations CRUD
- Coordination entre Views et Services
- Un ViewModel par écran complexe (pas pour les écrans triviaux)

### Services
- Logique métier **pure** : pas de dépendance SwiftUI ni SwiftData
- `BalanceCalculator` : prend `[Expense]`, retourne `BalanceResult`
- Entièrement testable unitairement
- Fonctions statiques ou struct sans état

### Models (SwiftData)
- Classes annotées `@Model`
- Propriétés stored + computed simples
- Relations via `@Relationship`
- Zéro logique métier complexe

## Types de sortie du BalanceCalculator

```swift
struct BalanceResult {
    let totalSpent: Decimal               // total toutes dépenses
    let partner1Spent: Decimal            // total payé par P1
    let partner2Spent: Decimal            // total payé par P2
    let partner1Share: Decimal            // part théorique P1
    let partner2Share: Decimal            // part théorique P2
    let netBalance: Decimal               // positif = P2 doit à P1
    let status: BalanceStatus
}

enum BalanceStatus {
    case partner2OwesPartner1(Decimal)    // P2 doit X à P1
    case partner1OwesPartner2(Decimal)    // P1 doit X à P2
    case balanced                         // équilibre
}
```

## SwiftData + iCloud

### Configuration dans DuoSpendApp.swift

```swift
@main
struct DuoSpendApp: App {
    var body: some Scene {
        WindowGroup {
            ProjectListView()
        }
        .modelContainer(for: [Project.self, Expense.self])
    }
}
```

Pour le MVP, on utilise la config par défaut de SwiftData (persistence locale + iCloud automatique si le user est connecté). Pas de config CloudKit manuelle.

### Migration
SwiftData gère les migrations légères automatiquement. Pour les migrations complexes (post-MVP), on utilisera `VersionedSchema`.

## Gestion des devises

- **MVP** : euro uniquement (€)
- Stockage : `Decimal` (jamais `Double`)
- Formatage : `.formatted(.currency(code: "EUR"))` avec `Locale.current`
- Cohérence : toujours 2 décimales à l'affichage

## Gestion d'erreurs

```swift
enum DuoSpendError: LocalizedError {
    case invalidAmount
    case invalidSplitRatio
    case projectNotFound
    case expenseNotFound

    var errorDescription: String? {
        switch self {
        case .invalidAmount: return "Le montant doit être supérieur à 0"
        case .invalidSplitRatio: return "La répartition doit totaliser 100%"
        case .projectNotFound: return "Projet introuvable"
        case .expenseNotFound: return "Dépense introuvable"
        }
    }
}
```

Affichage via `.alert` SwiftUI dans les Views.
