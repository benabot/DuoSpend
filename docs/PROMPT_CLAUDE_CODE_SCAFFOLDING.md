# Prompt Claude Code — Scaffolding DuoSpend

> Copie-colle ce prompt tel quel dans Claude Code depuis `/Users/benoitabot/Sites/DuoSpend`

---

## Contexte

Tu travailles sur **DuoSpend**, une app iOS SwiftUI/SwiftData.
Lis `CLAUDE.md` à la racine pour toutes les conventions, la structure cible et les modèles de données.
Lis `docs/MVP.md` pour la spec fonctionnelle.

Le projet Xcode **n'existe pas encore**. Tu dois le créer from scratch.

**Environnement :**
- macOS, Apple Silicon (arm64)
- Xcode.app installé dans `/Applications/Xcode.app`
- Swift 6.2 disponible
- ⚠️ Le developer directory pointe vers CommandLineTools. Commence par exécuter :
  ```bash
  sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
  ```
  puis vérifie avec `xcodebuild -version`

## Tâche

Crée le projet Xcode **DuoSpend** et tout le scaffolding initial dans `/Users/benoitabot/Sites/DuoSpend/`.

### Étape 1 — Fixer xcode-select

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -version
```

### Étape 2 — Créer le projet Xcode via template

Utilise la commande suivante pour générer le projet :

```bash
cd /Users/benoitabot/Sites/DuoSpend
```

Comme il n'y a pas de CLI `xcodebuild` pour créer un projet from scratch, **génère manuellement** les fichiers nécessaires :

1. **`DuoSpend.xcodeproj/project.pbxproj`** — fichier projet Xcode minimal
2. Ou bien, **alternative recommandée** : crée un `Package.swift` temporaire pour bootstrapper, puis génère le `.xcodeproj` avec `swift package generate-xcodeproj` — **NON**, cette approche est deprecated.

**Approche retenue** : crée le projet **directement depuis Xcode en ligne de commande** en utilisant un template de fichiers. Voici exactement ce qu'il faut faire :

### Étape 3 — Créer l'arborescence de fichiers Swift

Crée les dossiers et fichiers suivants (avec du code Swift fonctionnel) :

```
DuoSpend/
├── App/
│   └── DuoSpendApp.swift
├── Models/
│   ├── Project.swift
│   ├── Expense.swift
│   ├── PartnerRole.swift
│   └── SplitRatio.swift
├── Views/
│   ├── ProjectListView.swift
│   ├── CreateProjectView.swift
│   ├── ProjectDetailView.swift
│   ├── AddExpenseView.swift
│   └── Components/
│       ├── ProjectCard.swift
│       ├── ExpenseRow.swift
│       └── BalanceBanner.swift
├── ViewModels/
│   └── ProjectDetailViewModel.swift
├── Services/
│   └── BalanceCalculator.swift
├── Extensions/
│   └── Decimal+Currency.swift
├── Resources/
│   └── Assets.xcassets/
│       ├── Contents.json
│       ├── AccentColor.colorset/
│       │   └── Contents.json
│       └── AppIcon.appiconset/
│           └── Contents.json
└── Preview Content/
    └── SampleData.swift
```

Plus les dossiers de tests :
```
DuoSpendTests/
└── BalanceCalculatorTests.swift
```

### Étape 4 — Contenu des fichiers

#### `DuoSpend/App/DuoSpendApp.swift`

```swift
import SwiftUI
import SwiftData

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

#### `DuoSpend/Models/Project.swift`

```swift
import Foundation
import SwiftData

@Model
class Project {
    var name: String
    var emoji: String
    var budget: Decimal?
    var partner1Name: String
    var partner2Name: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \Expense.project)
    var expenses: [Expense] = []
    
    init(
        name: String,
        emoji: String = "💰",
        budget: Decimal? = nil,
        partner1Name: String,
        partner2Name: String,
        createdAt: Date = .now
    ) {
        self.name = name
        self.emoji = emoji
        self.budget = budget
        self.partner1Name = partner1Name
        self.partner2Name = partner2Name
        self.createdAt = createdAt
    }
}
```

#### `DuoSpend/Models/Expense.swift`

```swift
import Foundation
import SwiftData

@Model
class Expense {
    var title: String
    var amount: Decimal
    var paidByRawValue: String
    var splitRatioData: Data?
    var category: String?
    var date: Date
    
    var project: Project?
    
    /// Computed: PartnerRole depuis la valeur stockée
    var paidBy: PartnerRole {
        get { PartnerRole(rawValue: paidByRawValue) ?? .partner1 }
        set { paidByRawValue = newValue.rawValue }
    }
    
    /// Computed: SplitRatio depuis les données encodées
    var splitRatio: SplitRatio {
        get {
            guard let data = splitRatioData,
                  let ratio = try? JSONDecoder().decode(SplitRatio.self, from: data)
            else { return .equal }
            return ratio
        }
        set {
            splitRatioData = try? JSONEncoder().encode(newValue)
        }
    }
    
    init(
        title: String,
        amount: Decimal,
        paidBy: PartnerRole,
        splitRatio: SplitRatio = .equal,
        category: String? = nil,
        date: Date = .now
    ) {
        self.title = title
        self.amount = amount
        self.paidByRawValue = paidBy.rawValue
        self.splitRatioData = try? JSONEncoder().encode(splitRatio)
        self.category = category
        self.date = date
    }
}
```

> **Note importante** : SwiftData ne gère pas bien les enums avec associated values directement. On stocke `paidByRawValue` (String) et `splitRatioData` (Data encodée JSON), avec des computed properties pour l'accès typé.

#### `DuoSpend/Models/PartnerRole.swift`

```swift
import Foundation

enum PartnerRole: String, Codable, CaseIterable {
    case partner1
    case partner2
}
```

#### `DuoSpend/Models/SplitRatio.swift`

```swift
import Foundation

enum SplitRatio: Codable, Equatable {
    case equal
    case custom(partner1Share: Decimal, partner2Share: Decimal)
    
    /// Part du partenaire 1 (entre 0 et 1)
    var partner1Fraction: Decimal {
        switch self {
        case .equal:
            return 0.5
        case .custom(let p1Share, let p2Share):
            let total = p1Share + p2Share
            guard total > 0 else { return 0.5 }
            return p1Share / total
        }
    }
    
    /// Part du partenaire 2 (entre 0 et 1)
    var partner2Fraction: Decimal {
        return 1 - partner1Fraction
    }
}
```

#### `DuoSpend/Services/BalanceCalculator.swift`

```swift
import Foundation

/// Résultat du calcul de balance pour un projet
struct BalanceResult {
    let totalSpent: Decimal
    let partner1Spent: Decimal
    let partner2Spent: Decimal
    let partner1Share: Decimal
    let partner2Share: Decimal
    let netBalance: Decimal
    let status: BalanceStatus
}

/// Statut de la balance
enum BalanceStatus: Equatable {
    case partner2OwesPartner1(Decimal)
    case partner1OwesPartner2(Decimal)
    case balanced
}

/// Calculateur de balance — logique métier pure, sans dépendance SwiftUI/SwiftData
enum BalanceCalculator {
    
    /// Calcule la balance d'un projet à partir de ses dépenses
    static func calculate(expenses: [Expense]) -> BalanceResult {
        var totalSpent: Decimal = 0
        var partner1Spent: Decimal = 0
        var partner2Spent: Decimal = 0
        var partner1Share: Decimal = 0
        var partner2Share: Decimal = 0
        var netBalance: Decimal = 0
        
        for expense in expenses {
            let amount = expense.amount
            totalSpent += amount
            
            let p1Part = amount * expense.splitRatio.partner1Fraction
            let p2Part = amount * expense.splitRatio.partner2Fraction
            
            partner1Share += p1Part
            partner2Share += p2Part
            
            switch expense.paidBy {
            case .partner1:
                partner1Spent += amount
                netBalance += p2Part   // P2 doit sa part à P1
            case .partner2:
                partner2Spent += amount
                netBalance -= p1Part   // P1 doit sa part à P2
            }
        }
        
        let status: BalanceStatus
        if netBalance > 0 {
            status = .partner2OwesPartner1(netBalance)
        } else if netBalance < 0 {
            status = .partner1OwesPartner2(abs(netBalance))
        } else {
            status = .balanced
        }
        
        return BalanceResult(
            totalSpent: totalSpent,
            partner1Spent: partner1Spent,
            partner2Spent: partner2Spent,
            partner1Share: partner1Share,
            partner2Share: partner2Share,
            netBalance: netBalance,
            status: status
        )
    }
}
```

#### `DuoSpend/Extensions/Decimal+Currency.swift`

```swift
import Foundation

extension Decimal {
    /// Formate en devise EUR localisée (ex: "1 234,56 €" en fr_FR)
    var formattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale.current
        return formatter.string(from: self as NSDecimalNumber) ?? "0,00 €"
    }
}
```

#### `DuoSpend/Views/ProjectListView.swift`

```swift
import SwiftUI
import SwiftData

struct ProjectListView: View {
    @Query(sort: \Project.createdAt, order: .reverse) private var projects: [Project]
    @Environment(\.modelContext) private var modelContext
    @State private var showingCreateProject = false
    
    var body: some View {
        NavigationStack {
            Group {
                if projects.isEmpty {
                    emptyStateView
                } else {
                    projectsList
                }
            }
            .navigationTitle("DuoSpend")
            .toolbar {
                if !projects.isEmpty {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingCreateProject = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCreateProject) {
                CreateProjectView()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("Aucun projet", systemImage: "heart.fill")
        } description: {
            Text("Créez votre premier projet de couple pour commencer à suivre vos dépenses.")
        } actions: {
            Button("Créer un projet") {
                showingCreateProject = true
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - Projects List
    
    private var projectsList: some View {
        List {
            ForEach(projects) { project in
                NavigationLink(value: project) {
                    ProjectCard(project: project)
                }
            }
            .onDelete(perform: deleteProjects)
        }
        .navigationDestination(for: Project.self) { project in
            ProjectDetailView(project: project)
        }
    }
    
    private func deleteProjects(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(projects[index])
        }
    }
}

#Preview {
    ProjectListView()
        .modelContainer(SampleData.container)
}
```

#### `DuoSpend/Views/CreateProjectView.swift`

```swift
import SwiftUI

struct CreateProjectView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var emoji = "💰"
    @State private var partner1Name = ""
    @State private var partner2Name = ""
    @State private var budgetText = ""
    
    private var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
        && !partner1Name.trimmingCharacters(in: .whitespaces).isEmpty
        && !partner2Name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Projet") {
                    TextField("Nom du projet", text: $name)
                    // TODO: Emoji picker — pour l'instant un TextField simple
                    TextField("Emoji", text: $emoji)
                }
                
                Section("Partenaires") {
                    TextField("Partenaire 1", text: $partner1Name)
                    TextField("Partenaire 2", text: $partner2Name)
                }
                
                Section("Budget (optionnel)") {
                    TextField("0,00 €", text: $budgetText)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Nouveau projet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Créer") { createProject() }
                        .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func createProject() {
        let budget = Decimal(string: budgetText.replacingOccurrences(of: ",", with: "."))
        
        let project = Project(
            name: name.trimmingCharacters(in: .whitespaces),
            emoji: emoji,
            budget: budget,
            partner1Name: partner1Name.trimmingCharacters(in: .whitespaces),
            partner2Name: partner2Name.trimmingCharacters(in: .whitespaces)
        )
        
        modelContext.insert(project)
        dismiss()
    }
}

#Preview {
    CreateProjectView()
        .modelContainer(SampleData.container)
}
```

#### `DuoSpend/Views/ProjectDetailView.swift`

```swift
import SwiftUI
import SwiftData

struct ProjectDetailView: View {
    let project: Project
    @State private var showingAddExpense = false
    
    private var balance: BalanceResult {
        BalanceCalculator.calculate(expenses: project.expenses)
    }
    
    var body: some View {
        List {
            // MARK: - Balance
            Section {
                BalanceBanner(
                    balance: balance,
                    partner1Name: project.partner1Name,
                    partner2Name: project.partner2Name
                )
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            // MARK: - Budget progress
            if let budget = project.budget, budget > 0 {
                Section("Budget") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(balance.totalSpent.formattedCurrency) / \(budget.formattedCurrency)")
                            .font(.subheadline)
                        ProgressView(
                            value: Double(truncating: balance.totalSpent as NSDecimalNumber),
                            total: Double(truncating: budget as NSDecimalNumber)
                        )
                    }
                }
            }
            
            // MARK: - Expenses
            Section("Dépenses (\(project.expenses.count))") {
                if project.expenses.isEmpty {
                    Text("Aucune dépense — tapez + pour commencer")
                        .foregroundStyle(.secondary)
                } else {
                    let sorted = project.expenses.sorted { $0.date > $1.date }
                    ForEach(sorted) { expense in
                        ExpenseRow(
                            expense: expense,
                            partner1Name: project.partner1Name,
                            partner2Name: project.partner2Name
                        )
                    }
                }
            }
        }
        .navigationTitle("\(project.emoji) \(project.name)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(project: project)
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: SampleData.sampleProject)
    }
    .modelContainer(SampleData.container)
}
```

#### `DuoSpend/Views/AddExpenseView.swift`

```swift
import SwiftUI

struct AddExpenseView: View {
    let project: Project
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var amountText = ""
    @State private var paidBy: PartnerRole = .partner1
    @State private var isCustomSplit = false
    @State private var partner1ShareText = "50"
    @State private var date = Date.now
    
    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
        && Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) ?? 0 > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dépense") {
                    TextField("Restaurant, hôtel...", text: $title)
                    TextField("0,00 €", text: $amountText)
                        .keyboardType(.decimalPad)
                }
                
                Section("Payé par") {
                    Picker("Payé par", selection: $paidBy) {
                        Text(project.partner1Name).tag(PartnerRole.partner1)
                        Text(project.partner2Name).tag(PartnerRole.partner2)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Répartition") {
                    Picker("Répartition", selection: $isCustomSplit) {
                        Text("50 / 50").tag(false)
                        Text("Custom").tag(true)
                    }
                    .pickerStyle(.segmented)
                    
                    if isCustomSplit {
                        HStack {
                            Text(project.partner1Name)
                            TextField("50", text: $partner1ShareText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            Text("%")
                        }
                        HStack {
                            Text(project.partner2Name)
                            Spacer()
                            Text("\(100 - (Int(partner1ShareText) ?? 50))%")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Nouvelle dépense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") { addExpense() }
                        .disabled(!isFormValid)
                }
            }
        }
    }
    
    private func addExpense() {
        guard let amount = Decimal(string: amountText.replacingOccurrences(of: ",", with: ".")) else { return }
        
        let splitRatio: SplitRatio
        if isCustomSplit, let p1 = Int(partner1ShareText) {
            splitRatio = .custom(
                partner1Share: Decimal(p1),
                partner2Share: Decimal(100 - p1)
            )
        } else {
            splitRatio = .equal
        }
        
        let expense = Expense(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: amount,
            paidBy: paidBy,
            splitRatio: splitRatio,
            date: date
        )
        expense.project = project
        modelContext.insert(expense)
        dismiss()
    }
}

#Preview {
    AddExpenseView(project: SampleData.sampleProject)
        .modelContainer(SampleData.container)
}
```

#### `DuoSpend/Views/Components/ProjectCard.swift`

```swift
import SwiftUI

struct ProjectCard: View {
    let project: Project
    
    private var balance: BalanceResult {
        BalanceCalculator.calculate(expenses: project.expenses)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(project.emoji)
                    .font(.title2)
                Text(project.name)
                    .font(.headline)
            }
            
            Text("\(balance.totalSpent.formattedCurrency) dépensés")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            balanceLabel
                .font(.caption)
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var balanceLabel: some View {
        switch balance.status {
        case .partner2OwesPartner1(let amount):
            Text("\(project.partner2Name) doit \(amount.formattedCurrency) à \(project.partner1Name)")
                .foregroundStyle(.blue)
        case .partner1OwesPartner2(let amount):
            Text("\(project.partner1Name) doit \(amount.formattedCurrency) à \(project.partner2Name)")
                .foregroundStyle(.pink)
        case .balanced:
            Text("Équilibre ✅")
                .foregroundStyle(.green)
        }
    }
}

#Preview {
    ProjectCard(project: SampleData.sampleProject)
        .modelContainer(SampleData.container)
}
```

#### `DuoSpend/Views/Components/ExpenseRow.swift`

```swift
import SwiftUI

struct ExpenseRow: View {
    let expense: Expense
    let partner1Name: String
    let partner2Name: String
    
    private var payerName: String {
        expense.paidBy == .partner1 ? partner1Name : partner2Name
    }
    
    private var payerColor: Color {
        expense.paidBy == .partner1 ? .blue : .pink
    }
    
    var body: some View {
        HStack {
            Circle()
                .fill(payerColor)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(expense.title)
                    .font(.body)
                Text("\(payerName) · \(expense.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(expense.amount.formattedCurrency)
                .font(.body)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ExpenseRow(
        expense: SampleData.sampleExpense,
        partner1Name: "Marie",
        partner2Name: "Thomas"
    )
    .modelContainer(SampleData.container)
}
```

#### `DuoSpend/Views/Components/BalanceBanner.swift`

```swift
import SwiftUI

struct BalanceBanner: View {
    let balance: BalanceResult
    let partner1Name: String
    let partner2Name: String
    
    var body: some View {
        VStack(spacing: 4) {
            switch balance.status {
            case .partner2OwesPartner1(let amount):
                Text("\(partner2Name) doit")
                    .font(.subheadline)
                Text(amount.formattedCurrency)
                    .font(.title)
                    .fontWeight(.bold)
                Text("à \(partner1Name)")
                    .font(.subheadline)
            case .partner1OwesPartner2(let amount):
                Text("\(partner1Name) doit")
                    .font(.subheadline)
                Text(amount.formattedCurrency)
                    .font(.title)
                    .fontWeight(.bold)
                Text("à \(partner2Name)")
                    .font(.subheadline)
            case .balanced:
                Text("Vous êtes à l'équilibre ✅")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(backgroundColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private var backgroundColor: Color {
        switch balance.status {
        case .partner2OwesPartner1: return .blue
        case .partner1OwesPartner2: return .pink
        case .balanced: return .green
        }
    }
}

#Preview {
    BalanceBanner(
        balance: BalanceCalculator.calculate(expenses: SampleData.sampleProject.expenses),
        partner1Name: "Marie",
        partner2Name: "Thomas"
    )
    .modelContainer(SampleData.container)
}
```

#### `DuoSpend/Preview Content/SampleData.swift`

```swift
import SwiftData
import Foundation

@MainActor
enum SampleData {
    static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(
            for: Project.self, Expense.self,
            configurations: config
        )
        
        // Insérer les données sample
        let project = sampleProject
        container.mainContext.insert(project)
        
        for expense in sampleExpenses {
            expense.project = project
            container.mainContext.insert(expense)
        }
        
        return container
    }()
    
    static let sampleProject = Project(
        name: "Mariage",
        emoji: "💒",
        budget: 5000,
        partner1Name: "Marie",
        partner2Name: "Thomas"
    )
    
    static let sampleExpenses: [Expense] = [
        Expense(title: "Restaurant Le Zinc", amount: 80, paidBy: .partner1),
        Expense(title: "Essence", amount: 60, paidBy: .partner2),
        Expense(title: "Hôtel weekend", amount: 200, paidBy: .partner1,
                splitRatio: .custom(partner1Share: 70, partner2Share: 30)),
    ]
    
    static let sampleExpense = Expense(
        title: "Restaurant Le Zinc",
        amount: 80.50,
        paidBy: .partner1
    )
}
```

#### `DuoSpendTests/BalanceCalculatorTests.swift`

```swift
import Testing
@testable import DuoSpend

@Suite("BalanceCalculator")
struct BalanceCalculatorTests {
    
    @Test("Scénario 50/50 simple")
    func testEqual5050() {
        let expenses = [
            Expense(title: "Restaurant", amount: 80, paidBy: .partner1),
            Expense(title: "Essence", amount: 60, paidBy: .partner2),
        ]
        
        let result = BalanceCalculator.calculate(expenses: expenses)
        
        #expect(result.totalSpent == 140)
        #expect(result.netBalance == 10) // P2 doit 10€ à P1
        #expect(result.status == .partner2OwesPartner1(10))
    }
    
    @Test("Mix 50/50 et custom split")
    func testMixedSplit() {
        let expenses = [
            Expense(title: "Restaurant", amount: 80, paidBy: .partner1),
            Expense(title: "Essence", amount: 60, paidBy: .partner2),
            Expense(title: "Hôtel", amount: 200, paidBy: .partner1,
                    splitRatio: .custom(partner1Share: 70, partner2Share: 30)),
        ]
        
        let result = BalanceCalculator.calculate(expenses: expenses)
        
        #expect(result.totalSpent == 340)
        #expect(result.netBalance == 70) // Thomas doit 70€ à Marie
        #expect(result.status == .partner2OwesPartner1(70))
    }
    
    @Test("Équilibre parfait")
    func testPerfectBalance() {
        let expenses = [
            Expense(title: "Dîner", amount: 100, paidBy: .partner1),
            Expense(title: "Billets", amount: 100, paidBy: .partner2),
        ]
        
        let result = BalanceCalculator.calculate(expenses: expenses)
        
        #expect(result.netBalance == 0)
        #expect(result.status == .balanced)
    }
    
    @Test("Une seule dépense custom")
    func testSingleCustomExpense() {
        let expenses = [
            Expense(title: "Location voiture", amount: 300, paidBy: .partner2,
                    splitRatio: .custom(partner1Share: 60, partner2Share: 40)),
        ]
        
        let result = BalanceCalculator.calculate(expenses: expenses)
        
        // P2 a payé 300€, part P1 = 180€, donc P1 doit 180€ à P2
        #expect(result.status == .partner1OwesPartner2(180))
    }
    
    @Test("Aucune dépense")
    func testNoExpenses() {
        let result = BalanceCalculator.calculate(expenses: [])
        
        #expect(result.totalSpent == 0)
        #expect(result.status == .balanced)
    }
}
```

### Étape 5 — Créer le projet Xcode `.xcodeproj`

Une fois tous les fichiers Swift créés, ouvre Xcode pour générer le projet :

```bash
# Ouvrir Xcode pour créer le projet manuellement
# OU utiliser le trick : créer un projet Xcode vide puis ajouter les fichiers
open -a Xcode /Users/benoitabot/Sites/DuoSpend/
```

**Alternative plus fiable** : utilise `xcodegen` si disponible :

```bash
# Vérifier si xcodegen est installé
which xcodegen || brew install xcodegen
```

Si xcodegen est disponible, crée un fichier `project.yml` :

```yaml
name: DuoSpend
options:
  bundleIdPrefix: fr.beabot
  deploymentTarget:
    iOS: "17.0"
  xcodeVersion: "16.0"
  createIntermediateGroups: true
settings:
  SWIFT_VERSION: "6.0"
  DEVELOPMENT_TEAM: ""
targets:
  DuoSpend:
    type: application
    platform: iOS
    sources:
      - DuoSpend
    settings:
      INFOPLIST_GENERATION: YES
      MARKETING_VERSION: "1.0.0"
      CURRENT_PROJECT_VERSION: 1
      GENERATE_INFOPLIST_FILE: YES
      INFOPLIST_KEY_UIApplicationSceneManifest_Generation: YES
      INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents: YES
      INFOPLIST_KEY_UILaunchScreen_Generation: YES
      INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone: "UIInterfaceOrientationPortrait"
  DuoSpendTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - DuoSpendTests
    dependencies:
      - target: DuoSpend
    settings:
      INFOPLIST_GENERATION: YES
      GENERATE_INFOPLIST_FILE: YES
```

Puis :

```bash
cd /Users/benoitabot/Sites/DuoSpend
xcodegen generate
```

### Étape 6 — Vérifier

```bash
cd /Users/benoitabot/Sites/DuoSpend
xcodebuild -scheme DuoSpend -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -5
```

Le build doit réussir sans erreur.

## Contraintes

- Respecter les conventions de `CLAUDE.md`
- Architecture MVVM avec `@Observable`
- SwiftData `@Model` pour la persistance
- `Decimal` pour les montants, jamais `Double`
- Zéro dépendance tierce (sauf xcodegen pour le scaffolding)
- iOS 17+ minimum
- Tous les fichiers en UTF-8

## Critères de validation

- [ ] `xcodebuild build` réussit sans erreur
- [ ] Les Previews fonctionnent (SampleData opérationnel)
- [ ] `xcodebuild test` — les 5 tests du BalanceCalculator passent
- [ ] Parcours complet fonctionne dans le simulateur : créer projet → ajouter dépense → voir balance
- [ ] Structure de dossiers conforme au CLAUDE.md
