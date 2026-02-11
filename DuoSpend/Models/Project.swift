import Foundation
import SwiftData

/// Projet de couple regroupant des dépenses partagées
@Model
class Project {
    var name: String
    var emoji: String
    var budget: Decimal
    var partner1Name: String
    var partner2Name: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Expense.project)
    var expenses: [Expense] = []

    init(
        name: String,
        emoji: String = "💰",
        budget: Decimal,
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
