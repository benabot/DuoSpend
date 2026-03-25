import WidgetKit
import Foundation

/// Entrée de la timeline du widget
struct DuoSpendEntry: TimelineEntry {
    let date: Date
    let projectName: String
    let emoji: String
    let partner1Name: String
    let partner2Name: String
    let balanceStatus: WidgetBalanceStatus
    let totalSpent: String
    let partner1Spent: Decimal
    let partner2Spent: Decimal
    let recentExpenses: [WidgetExpense]
    var isLocked: Bool = false
}

/// Statut de balance simplifié pour le widget
enum WidgetBalanceStatus: Sendable {
    case balanced
    case owes(debtor: String, creditor: String, amount: String)
}

/// Dépense simplifiée pour affichage dans le widget large
struct WidgetExpense: Sendable, Identifiable {
    let id: String
    let title: String
    let amount: String
    let paidByName: String
    let isPartner1: Bool
    let date: Date
}

extension DuoSpendEntry {
    /// Affiché quand l'utilisateur n'a pas DuoSpend Pro
    static let locked = DuoSpendEntry(
        date: .now,
        projectName: "DuoSpend Pro",
        emoji: "🔒",
        partner1Name: "",
        partner2Name: "",
        balanceStatus: .balanced,
        totalSpent: "",
        partner1Spent: 0,
        partner2Spent: 0,
        recentExpenses: [],
        isLocked: true
    )

    /// Données fictives pour placeholder et snapshot
    static let placeholder = DuoSpendEntry(
        date: .now,
        projectName: "\u{1F492} Mariage",
        emoji: "\u{1F492}",
        partner1Name: "Marie",
        partner2Name: "Thomas",
        balanceStatus: .owes(debtor: "Thomas", creditor: "Marie", amount: "45,00 \u{20AC}"),
        totalSpent: "1 240,00 \u{20AC}",
        partner1Spent: 780,
        partner2Spent: 460,
        recentExpenses: []
    )
}
