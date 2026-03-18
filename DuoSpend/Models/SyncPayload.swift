import Foundation

/// Payload de synchronisation envoyé entre deux appareils via MultipeerConnectivity.
/// Contient un projet complet avec toutes ses dépenses, sérialisé en JSON.
struct SyncPayload: Codable, Sendable, Equatable {
    let projectName: String
    let projectEmoji: String
    let projectBudget: Decimal
    let partner1Name: String
    let partner2Name: String
    let projectCreatedAt: Date
    let expenses: [SyncExpense]
    let syncTimestamp: Date

    /// Crée un payload à partir d'un projet SwiftData et de ses dépenses.
    init(project: Project, expenses: [Expense]) {
        self.projectName = project.name
        self.projectEmoji = project.emoji
        self.projectBudget = project.budget
        self.partner1Name = project.partner1Name
        self.partner2Name = project.partner2Name
        self.projectCreatedAt = project.createdAt
        self.expenses = expenses.map { SyncExpense(expense: $0) }
        self.syncTimestamp = .now
    }

    /// Initialisation directe pour les tests.
    init(
        projectName: String,
        projectEmoji: String,
        projectBudget: Decimal,
        partner1Name: String,
        partner2Name: String,
        projectCreatedAt: Date,
        expenses: [SyncExpense],
        syncTimestamp: Date = .now
    ) {
        self.projectName = projectName
        self.projectEmoji = projectEmoji
        self.projectBudget = projectBudget
        self.partner1Name = partner1Name
        self.partner2Name = partner2Name
        self.projectCreatedAt = projectCreatedAt
        self.expenses = expenses
        self.syncTimestamp = syncTimestamp
    }
}

/// Représentation Codable d'une dépense pour le transport peer-to-peer.
struct SyncExpense: Codable, Sendable, Equatable {
    let title: String
    let amount: Decimal
    let paidBy: PartnerRole
    let splitRatio: SplitRatio
    let category: String?
    let date: Date

    /// Crée une SyncExpense à partir d'une Expense SwiftData.
    init(expense: Expense) {
        self.title = expense.title
        self.amount = expense.amount
        self.paidBy = expense.paidBy
        self.splitRatio = expense.splitRatio
        self.category = expense.category
        self.date = expense.date
    }

    /// Initialisation directe pour les tests.
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
        self.paidBy = paidBy
        self.splitRatio = splitRatio
        self.category = category
        self.date = date
    }
}
