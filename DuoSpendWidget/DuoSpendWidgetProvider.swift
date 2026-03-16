import WidgetKit
import SwiftData
import Foundation

/// Fournit les données au widget en lisant SwiftData depuis le container partagé (App Group)
struct DuoSpendWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = DuoSpendEntry
    typealias Intent = ConfigurationAppIntent

    func placeholder(in context: Context) -> DuoSpendEntry {
        .placeholder
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> DuoSpendEntry {
        await loadEntry() ?? .placeholder
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<DuoSpendEntry> {
        let entry = await loadEntry() ?? .placeholder
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: .now)
        return Timeline(entries: [entry], policy: .after(nextUpdate ?? .now))
    }

    /// Charge le projet le plus récent depuis SwiftData (lecture seule)
    @MainActor
    private func loadEntry() -> DuoSpendEntry? {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.fr.beabot.DuoSpend"
        ) else { return nil }

        let storeURL = groupURL.appendingPathComponent("DuoSpend.store")
        let schema = Schema([Project.self, Expense.self])
        let config = ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)

        guard let container = try? ModelContainer(for: schema, configurations: [config]) else {
            return nil
        }

        let context = container.mainContext
        var descriptor = FetchDescriptor<Project>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1

        guard let project = try? context.fetch(descriptor).first else {
            return nil
        }

        let expenses = project.expenses
        let balance = BalanceCalculator.calculate(expenses: expenses)

        let status: WidgetBalanceStatus
        switch balance.status {
        case .balanced:
            status = .balanced
        case .partner2OwesPartner1(let amount):
            status = .owes(
                debtor: project.partner2Name,
                creditor: project.partner1Name,
                amount: amount.formattedCurrency
            )
        case .partner1OwesPartner2(let amount):
            status = .owes(
                debtor: project.partner1Name,
                creditor: project.partner2Name,
                amount: amount.formattedCurrency
            )
        }

        let recentExpenses: [WidgetExpense] = expenses
            .sorted { $0.date > $1.date }
            .prefix(3)
            .map { expense in
                WidgetExpense(
                    id: expense.title + expense.date.description,
                    title: expense.title,
                    amount: expense.amount.formattedCurrency,
                    paidByName: expense.paidBy == .partner1
                        ? project.partner1Name
                        : project.partner2Name,
                    isPartner1: expense.paidBy == .partner1,
                    date: expense.date
                )
            }

        return DuoSpendEntry(
            date: .now,
            projectName: "\(project.emoji) \(project.name)",
            emoji: project.emoji,
            partner1Name: project.partner1Name,
            partner2Name: project.partner2Name,
            balanceStatus: status,
            totalSpent: balance.totalSpent.formattedCurrency,
            partner1Spent: balance.partner1Spent,
            partner2Spent: balance.partner2Spent,
            recentExpenses: recentExpenses
        )
    }
}
