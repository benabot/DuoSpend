import SwiftUI
import SwiftData

/// Ordre de tri des dépenses
enum ExpenseSortOrder: String, CaseIterable {
    case date = "Date"
    case amount = "Montant"
    case payer = "Payeur"

    var icon: String {
        switch self {
        case .date: return "calendar"
        case .amount: return "eurosign"
        case .payer: return "person.fill"
        }
    }

    /// Localizable label (rawValue is the French key in Localizable.xcstrings)
    var label: LocalizedStringKey { LocalizedStringKey(rawValue) }
}

/// Détail d'un projet : balance, budget, liste des dépenses
struct ProjectDetailView: View {
    @Bindable var project: Project
    @Query private var allExpenses: [Expense]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    /// Dépenses filtrées pour ce projet — utilise @Query pour garantir des données fraîches
    private var projectExpenses: [Expense] {
        allExpenses.filter { $0.project?.persistentModelID == project.persistentModelID }
    }

    @State private var showingAddExpense = false
    @State private var showingEditProject = false
    @State private var showingDeleteConfirmation = false
    @State private var expenseToEdit: Expense?
    @State private var sortOrder: ExpenseSortOrder = .date
    @State private var showAllExpenses = false
    @State private var pdfURL: URL?

    // Préview limitée : les 5 plus récentes, toutes si showAllExpenses
    private let previewCount = 5

    private var balance: BalanceResult {
        BalanceCalculator.calculate(expenses: projectExpenses)
    }

    private var sortedExpenses: [Expense] {
        switch sortOrder {
        case .date:   projectExpenses.sorted { $0.date > $1.date }
        case .amount: projectExpenses.sorted { $0.amount > $1.amount }
        case .payer:  projectExpenses.sorted { $0.paidByRawValue < $1.paidByRawValue }
        }
    }

    private var displayedExpenses: [Expense] {
        showAllExpenses ? sortedExpenses : Array(sortedExpenses.prefix(previewCount))
    }

    private var expenseCountLabel: String {
        localizedExpenseCount(projectExpenses.count)
    }

    private var budgetFraction: Double {
        guard project.budget > 0 else { return 0 }
        let spent  = Double(truncating: balance.totalSpent as NSDecimalNumber)
        let budget = Double(truncating: project.budget as NSDecimalNumber)
        return min(spent / budget, 1.0)
    }

    private var isOverBudget: Bool { balance.totalSpent > project.budget && project.budget > 0 }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {

                // ── Résumé projet ─────────────────────────────────────
                projectSummaryCard
                    .padding(.horizontal)
                    .padding(.top, 8)

                // ── Balance (toujours visible) ────────────────────────
                BalanceBanner(
                    balance: balance,
                    partner1Name: project.partner1Name,
                    partner2Name: project.partner2Name
                )

                // ── Contributions ─────────────────────────────────────
                if !projectExpenses.isEmpty {
                    duoStatsCard
                        .padding(.horizontal)
                }

                // ── Dépenses ──────────────────────────────────────────
                expensesSection

                // ── Empty state ───────────────────────────────────────
                if projectExpenses.isEmpty {
                    emptyState
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color.warmBackground.ignoresSafeArea())
        .navigationTitle(project.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { toolbarContent }
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
        .onChange(of: pdfURL) {
            guard let url = pdfURL else { return }
            let avc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.keyWindow?.rootViewController {
                let presenter = root.presentedViewController ?? root
                presenter.present(avc, animated: true)
            }
            pdfURL = nil
        }
        .alert("Supprimer le projet ?", isPresented: $showingDeleteConfirmation) {
            Button("Supprimer", role: .destructive) {
                modelContext.delete(project)
                dismiss()
            }
            Button("Annuler", role: .cancel) { }
        } message: {
            Text("Supprimer « \(project.name) » et toutes ses dépenses ?")
        }
    }

    // MARK: - Project Summary Card

    private var projectSummaryCard: some View {
        VStack(spacing: 16) {
            // Header : avatars + infos
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(Color.partner1.gradient)
                    Text(String(project.partner1Name.prefix(1)).uppercased())
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)

                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(Color.accentPrimary.opacity(0.5))

                ZStack {
                    Circle().fill(Color.partner2.gradient)
                    Text(String(project.partner2Name.prefix(1)).uppercased())
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(expenseCountLabel)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                    Text("Créé le \(project.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.system(.caption2, design: .rounded))
                }
                .foregroundStyle(.secondary)
            }

            // Trio de chiffres si budget > 0
            if project.budget > 0 {
                HStack(spacing: 0) {
                    summaryFigure(
                        value: balance.totalSpent.formattedCurrency,
                        label: "dépensé",
                        color: isOverBudget ? .red : .primary
                    )
                    summaryFigure(
                        value: project.budget.formattedCurrency,
                        label: "budget",
                        color: .secondary
                    )
                    let remaining = project.budget - balance.totalSpent
                    summaryFigure(
                        value: remaining.formattedCurrency,
                        label: remaining >= 0 ? "restant" : "dépassé",
                        color: remaining >= 0 ? Color.successGreen : .red
                    )
                }

                // Barre de progression budget
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.12))
                        Capsule()
                            .fill(isOverBudget ? Color.red.gradient : Color.accentPrimary.gradient)
                            .frame(width: geo.size.width * budgetFraction)
                            .animation(.spring(duration: 0.7), value: budgetFraction)
                    }
                }
                .frame(height: 8)
                .clipShape(Capsule())

                HStack {
                    Group {
                        if isOverBudget {
                            Text("⚠ Budget dépassé")
                        } else {
                            Text("\(String(Int(budgetFraction * 100)))% utilisé")
                        }
                    }
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(isOverBudget ? .red : .secondary)
                    Spacer()
                }
            }
        }
        .padding(18)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: shadowColor, radius: 10, y: 4)
    }

    private func summaryFigure(value: String, label: LocalizedStringKey, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(color)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Contributions (Paye / Part finale / Difference)

    private var duoStatsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Label("Contributions", systemImage: "chart.bar.fill")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.accentPrimary)

                Text("Compare ce que chacun a payé avec sa part finale.")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            // En-tête colonnes
            HStack(spacing: 0) {
                Spacer()
                columnHeader("Payé")
                columnHeader("Part finale")
                columnHeader("Différence")
            }

            Divider()

            contributionRow(
                name: project.partner1Name,
                color: .partner1,
                paid: balance.partner1Paid,
                part: balance.partner1Due,
                net: balance.partner1Net
            )
            contributionRow(
                name: project.partner2Name,
                color: .partner2,
                paid: balance.partner2Paid,
                part: balance.partner2Due,
                net: balance.partner2Net
            )

            Divider()

            // Ligne Total — verifie visuellement que Paye = Part finale = totalSpent
            HStack(spacing: 0) {
                Text("Total")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(balance.totalSpent.formattedCurrency)
                    .frame(width: columnWidth, alignment: .trailing)
                    .monospacedDigit()
                Text(balance.totalSpent.formattedCurrency)
                    .frame(width: columnWidth, alignment: .trailing)
                    .monospacedDigit()
                HStack(spacing: 3) {
                    Text(Decimal.zero.formattedCurrency).monospacedDigit()
                    Image(systemName: "checkmark")
                        .font(.caption2)
                        .foregroundStyle(Color.successGreen)
                }
                .frame(width: columnWidth, alignment: .trailing)
            }
            .font(.system(.caption, design: .rounded))
            .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: shadowColor, radius: 10, y: 4)
    }

    private let columnWidth: CGFloat = 72

    private func columnHeader(_ text: LocalizedStringKey) -> some View {
        Text(text)
            .frame(width: columnWidth, alignment: .trailing)
            .font(.system(.caption2, design: .rounded))
            .foregroundStyle(.secondary)
    }

    private func contributionRow(name: String, color: Color, paid: Decimal, part: Decimal, net: Decimal) -> some View {
        HStack(spacing: 0) {
            HStack(spacing: 6) {
                Circle().fill(color).frame(width: 8, height: 8)
                Text(name).fontWeight(.medium)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(paid.formattedCurrency)
                .frame(width: columnWidth, alignment: .trailing)
                .monospacedDigit()
            Text(part.formattedCurrency)
                .frame(width: columnWidth, alignment: .trailing)
                .monospacedDigit()
            Text(signedCurrency(net))
                .fontWeight(.semibold)
                .foregroundStyle(net >= 0 ? Color.successGreen : Color.red)
                .frame(width: columnWidth, alignment: .trailing)
                .monospacedDigit()
        }
        .font(.system(.caption, design: .rounded))
    }

    /// Formate un solde net avec signe explicite : "+33,00 €" ou "−33,00 €"
    private func signedCurrency(_ value: Decimal) -> String {
        value > 0 ? "+\(value.formattedCurrency)" : value.formattedCurrency
    }

    private func localizedExpenseCount(_ count: Int) -> String {
        let usesEnglish = Locale.autoupdatingCurrent.language.languageCode?.identifier == "en"
        if usesEnglish {
            return count == 1 ? "1 expense" : "\(count) expenses"
        }
        return count == 1 ? "1 dépense" : "\(count) dépenses"
    }

    // MARK: - Dépenses

    private var expensesSection: some View {
        VStack(spacing: 0) {
            // Header section
            HStack {
                Text("Dépenses")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                Spacer()
                // Picker tri compact
                Menu {
                    Picker("Trier par", selection: $sortOrder) {
                        ForEach(ExpenseSortOrder.allCases, id: \.self) { order in
                            Label(order.label, systemImage: order.icon).tag(order)
                        }
                    }
                } label: {
                    Label(sortOrder.label, systemImage: "arrow.up.arrow.down")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.accentPrimary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.accentPrimary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            if !projectExpenses.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(displayedExpenses.enumerated()), id: \.element.id) { index, expense in
                        Button { expenseToEdit = expense } label: {
                            ExpenseRow(
                                expense: expense,
                                partner1Name: project.partner1Name,
                                partner2Name: project.partner2Name
                            )
                            .padding(.horizontal, 18)
                            .padding(.vertical, 2)
                        }
                        .tint(.primary)
                        .contextMenu {
                            Button { expenseToEdit = expense } label: {
                                Label("Modifier", systemImage: "pencil")
                            }
                            Divider()
                            Button(role: .destructive) {
                                modelContext.delete(expense)
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }

                        if index < displayedExpenses.count - 1 {
                            Divider()
                                .padding(.leading, 70)
                                .padding(.trailing, 18)
                        }
                    }

                    // Bouton "Voir tout"
                    if sortedExpenses.count > previewCount && !showAllExpenses {
                        Divider().padding(.horizontal, 18)
                        Button {
                            withAnimation(.spring(response: 0.4)) { showAllExpenses = true }
                        } label: {
                            Label(
                                "Voir les \(sortedExpenses.count - previewCount) autres",
                                systemImage: "chevron.down"
                            )
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(Color.accentPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                        }
                    }
                }
                .background(cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: shadowColor, radius: 10, y: 4)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart.badge.plus")
                .font(.system(size: 52))
                .foregroundStyle(Color.accentPrimary.opacity(0.5))
                .symbolEffect(.pulse)

            VStack(spacing: 6) {
                Text("Aucune dépense")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                Text("Tapez + pour ajouter\nla première dépense")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingAddExpense = true
            } label: {
                Label("Ajouter une dépense", systemImage: "plus")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentPrimary)
            .controlSize(.regular)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal)
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingAddExpense = true
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }
            .tint(Color.accentPrimary)
        }
        ToolbarItem(placement: .secondaryAction) {
            Menu {
                Button {
                    showingEditProject = true
                } label: {
                    Label("Modifier le projet", systemImage: "pencil")
                }
                Button {
                    do {
                        pdfURL = try PDFExportService.generatePDF(
                            project: project,
                            expenses: projectExpenses,
                            balance: balance
                        )
                    } catch {
                        // Silencieux pour MVP
                    }
                } label: {
                    Label("Exporter en PDF", systemImage: "square.and.arrow.up")
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
            .tint(Color.accentPrimary)
        }
    }

    // MARK: - Helpers

    private var cardBg: some ShapeStyle {
        colorScheme == .dark
            ? AnyShapeStyle(Color(.secondarySystemGroupedBackground))
            : AnyShapeStyle(Color.cardBackground)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.25) : .black.opacity(0.06)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        ProjectDetailView(project: SampleData.sampleProject)
    }
    .modelContainer(SampleData.container)
}
#endif
