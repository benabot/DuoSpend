import Foundation
import Testing
import SwiftData
@testable import DuoSpend

@Suite("SyncMergeService")
struct SyncMergeServiceTests {

    /// Crée un ModelContainer en mémoire pour les tests (sans CloudKit).
    private func makeContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
        let container = try ModelContainer(for: Project.self, Expense.self, configurations: config)
        return ModelContext(container)
    }

    // MARK: - Création

    @Test("Merge dans un contexte vide crée le projet et ses dépenses")
    func mergeIntoEmptyContext() throws {
        let context = try makeContext()
        let payload = SyncPayload(
            projectName: "Voyage",
            projectEmoji: "✈️",
            projectBudget: 2000,
            partner1Name: "Marie",
            partner2Name: "Thomas",
            projectCreatedAt: Date(timeIntervalSince1970: 1_700_000_000),
            expenses: [
                SyncExpense(title: "Avion", amount: 600, paidBy: .partner1),
                SyncExpense(title: "Hôtel", amount: 400, paidBy: .partner2),
            ]
        )

        let added = try SyncMergeService.merge(payload: payload, into: context)

        #expect(added == 2)

        let projects = try context.fetch(FetchDescriptor<Project>())
        #expect(projects.count == 1)
        #expect(projects.first?.name == "Voyage")
        #expect(projects.first?.expenses.count == 2)
    }

    @Test("Merge quand le projet existe déjà ajoute seulement les nouvelles dépenses")
    func mergeIntoExistingProject() throws {
        let context = try makeContext()

        // Créer un projet existant avec une dépense
        let project = Project(
            name: "Mariage",
            emoji: "💒",
            budget: 5000,
            partner1Name: "Alice",
            partner2Name: "Bob"
        )
        context.insert(project)
        let existingExpense = Expense(
            title: "Traiteur",
            amount: 1500,
            paidBy: .partner1,
            date: Date(timeIntervalSince1970: 1_700_000_000)
        )
        existingExpense.project = project
        context.insert(existingExpense)

        // Payload avec la même dépense + une nouvelle
        let payload = SyncPayload(
            projectName: "Mariage",
            projectEmoji: "💒",
            projectBudget: 5000,
            partner1Name: "Alice",
            partner2Name: "Bob",
            projectCreatedAt: project.createdAt,
            expenses: [
                SyncExpense(
                    title: "Traiteur",
                    amount: 1500,
                    paidBy: .partner1,
                    date: Date(timeIntervalSince1970: 1_700_000_000)
                ),
                SyncExpense(title: "Fleurs", amount: 300, paidBy: .partner2),
            ]
        )

        let added = try SyncMergeService.merge(payload: payload, into: context)

        #expect(added == 1)  // seule "Fleurs" est ajoutée
        #expect(project.expenses.count == 2)
    }

    @Test("Dédoublonnage : même title + amount + date → ignoré")
    func deduplication() throws {
        let context = try makeContext()

        let fixedDate = Date(timeIntervalSince1970: 1_700_000_000)
        let project = Project(
            name: "Courses",
            emoji: "🛒",
            budget: 500,
            partner1Name: "Léa",
            partner2Name: "Paul"
        )
        context.insert(project)
        let expense = Expense(title: "Carrefour", amount: 85, paidBy: .partner1, date: fixedDate)
        expense.project = project
        context.insert(expense)

        let payload = SyncPayload(
            projectName: "Courses",
            projectEmoji: "🛒",
            projectBudget: 500,
            partner1Name: "Léa",
            partner2Name: "Paul",
            projectCreatedAt: project.createdAt,
            expenses: [
                SyncExpense(title: "Carrefour", amount: 85, paidBy: .partner1, date: fixedDate),
            ]
        )

        let added = try SyncMergeService.merge(payload: payload, into: context)

        #expect(added == 0)
        #expect(project.expenses.count == 1)
    }

    @Test("Payload avec 0 dépenses crée le projet sans erreur")
    func emptyExpenses() throws {
        let context = try makeContext()
        let payload = SyncPayload(
            projectName: "Vide",
            projectEmoji: "📭",
            projectBudget: 100,
            partner1Name: "X",
            partner2Name: "Y",
            projectCreatedAt: .now,
            expenses: []
        )

        let added = try SyncMergeService.merge(payload: payload, into: context)

        #expect(added == 0)
        let projects = try context.fetch(FetchDescriptor<Project>())
        #expect(projects.count == 1)
        #expect(projects.first?.expenses.isEmpty == true)
    }

    @Test("Encodage/décodage round-trip JSON de SyncPayload")
    func jsonRoundTrip() throws {
        let payload = SyncPayload(
            projectName: "Test",
            projectEmoji: "🧪",
            projectBudget: 999.99,
            partner1Name: "A",
            partner2Name: "B",
            projectCreatedAt: Date(timeIntervalSince1970: 1_700_000_000),
            expenses: [
                SyncExpense(
                    title: "Dîner",
                    amount: 42.50,
                    paidBy: .partner2,
                    splitRatio: .custom(partner1Share: 60, partner2Share: 40),
                    category: "Resto",
                    date: Date(timeIntervalSince1970: 1_700_001_000)
                ),
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(payload)
        let decoded = try JSONDecoder().decode(SyncPayload.self, from: data)

        #expect(decoded.projectName == payload.projectName)
        #expect(decoded.projectBudget == payload.projectBudget)
        #expect(decoded.expenses.count == 1)
        #expect(decoded.expenses.first?.title == "Dîner")
        #expect(decoded.expenses.first?.amount == 42.50)
        #expect(decoded.expenses.first?.paidBy == .partner2)
        #expect(decoded.expenses.first?.splitRatio == .custom(partner1Share: 60, partner2Share: 40))
        #expect(decoded.expenses.first?.category == "Resto")
    }
}
