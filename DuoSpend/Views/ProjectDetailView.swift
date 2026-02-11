import SwiftUI
import SwiftData

/// Ordre de tri des dépenses
enum ExpenseSortOrder: String, CaseIterable {
    case date = "Date"
    case amount = "Montant"
    case payer = "Payeur"
}

/// Détail d'un projet : balance, budget, liste des dépenses
struct ProjectDetailView: View {
    let project: Project
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingAddExpense = false
    @State private var showingEditProject = false
    @State private var showingDeleteConfirmation = false
    @State private var expenseToEdit: Expense?
    @State private var sortOrder: ExpenseSortOrder = .date

    private var balance: BalanceResult {
        BalanceCalculator.calculate(expenses: project.expenses)
    }

    private var sortedExpenses: [Expense] {
        switch sortOrder {
        case .date:
            project.expenses.sorted { $0.date > $1.date }
        case .amount:
            project.expenses.sorted { $0.amount > $1.amount }
        case .payer:
            project.expenses.sorted { $0.paidByRawValue < $1.paidByRawValue }
        }
    }

    private var p1ExpenseCount: Int {
        project.expenses.filter { $0.paidBy == .partner1 }.count
    }

    private var p2ExpenseCount: Int {
        project.expenses.filter { $0.paidBy == .partner2 }.count
    }

    private var p1Fraction: Double {
        guard balance.totalSpent > 0 else { return 0.5 }
        return Double(truncating: balance.partner1Spent as NSDecimalNumber)
            / Double(truncating: balance.totalSpent as NSDecimalNumber)
    }

    @ViewBuilder
    private var summaryContent: some View {
        LabeledContent(project.partner1Name) {
            Text(balance.partner1Spent.formattedCurrency)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .foregroundStyle(Color.partner1)
        }
        LabeledContent(project.partner2Name) {
            Text(balance.partner2Spent.formattedCurrency)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .foregroundStyle(Color.partner2)
        }
        LabeledContent("Nombre de dépenses") {
            Text("\(project.partner1Name) : \(p1ExpenseCount) · \(project.partner2Name) : \(p2ExpenseCount)")
                .font(.caption)
        }
        VStack(alignment: .leading, spacing: 4) {
            Text("Contribution")
                .font(.caption)
                .foregroundStyle(.secondary)
            GeometryReader { geo in
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.partner1)
                        .frame(width: max(geo.size.width * p1Fraction, 2))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.partner2)
                }
            }
            .frame(height: 8)
            .animation(.spring, value: p1Fraction)
            HStack {
                Text("\(Int(p1Fraction * 100))%")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Color.partner1)
                Spacer()
                Text("\(Int((1 - p1Fraction) * 100))%")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(Color.partner2)
            }
        }
    }

    var body: some View {
        List {
            // MARK: - Balance
            if project.expenses.isEmpty {
                Section {
                    Text("Ajoutez votre première dépense 🎉")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.accentPrimary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 12)
                }
                .listRowBackground(Color.clear)
            } else {
                Section {
                    BalanceBanner(
                        balance: balance,
                        partner1Name: project.partner1Name,
                        partner2Name: project.partner2Name
                    )
                }
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            // MARK: - Budget progress
            Section("Budget") {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(balance.totalSpent.formattedCurrency) / \(project.budget.formattedCurrency)")
                        .font(.system(.subheadline, design: .rounded))
                    ProgressView(
                        value: Double(truncating: balance.totalSpent as NSDecimalNumber),
                        total: Double(truncating: project.budget as NSDecimalNumber)
                    )
                    .tint(Color.accentPrimary)
                }
            }

            // MARK: - Summary
            if !project.expenses.isEmpty {
                Section {
                    DisclosureGroup("Résumé") {
                        summaryContent
                    }
                    .tint(Color.accentPrimary)
                }
            }

            // MARK: - Expenses
            Section("Dépenses (\(project.expenses.count))") {
                if project.expenses.isEmpty {
                    Text("Aucune dépense — tapez + pour commencer")
                        .foregroundStyle(.secondary)
                } else {
                    let sorted = sortedExpenses
                    ForEach(sorted) { expense in
                        Button {
                            expenseToEdit = expense
                        } label: {
                            ExpenseRow(
                                expense: expense,
                                partner1Name: project.partner1Name,
                                partner2Name: project.partner2Name
                            )
                        }
                        .tint(.primary)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                modelContext.delete(expense)
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.warmBackground)
        .navigationTitle("\(project.emoji) \(project.name)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddExpense = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Menu {
                    Button {
                        showingEditProject = true
                    } label: {
                        Label("Modifier le projet", systemImage: "pencil")
                    }
                    Picker("Trier par", selection: $sortOrder) {
                        ForEach(ExpenseSortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    Divider()
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Supprimer le projet", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .tint(Color.accentPrimary)
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(project: project)
        }
        .sheet(isPresented: $showingEditProject) {
            EditProjectView(project: project)
        }
        .sheet(item: $expenseToEdit) { expense in
            AddExpenseView(project: project, existingExpense: expense)
        }
        .alert("Supprimer le projet ?", isPresented: $showingDeleteConfirmation) {
            Button("Supprimer", role: .destructive) {
                modelContext.delete(project)
                dismiss()
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Supprimer \(project.name) et toutes ses dépenses ?")
        }
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: SampleData.sampleProject)
    }
    .modelContainer(SampleData.container)
}
