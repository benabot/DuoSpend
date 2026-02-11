import SwiftData
import Foundation

/// Données de preview pour les Previews SwiftUI
@MainActor
enum SampleData {
    static let container: ModelContainer = {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // swiftlint:disable:next force_try
        let container = try! ModelContainer(
            for: Project.self, Expense.self,
            configurations: config
        )

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
        Expense(
            title: "Hôtel weekend",
            amount: 200,
            paidBy: .partner1,
            splitRatio: .custom(partner1Share: 70, partner2Share: 30)
        ),
    ]

    static let sampleExpense = Expense(
        title: "Restaurant Le Zinc",
        amount: 80.50,
        paidBy: .partner1
    )
}
