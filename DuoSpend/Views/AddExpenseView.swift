import SwiftUI

/// Sheet d'ajout ou d'édition d'une dépense — design card natif
struct AddExpenseView: View {
    let project: Project
    var existingExpense: Expense?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var title = ""
    @State private var amountText = ""
    @State private var paidBy: PartnerRole = .partner1
    @State private var isCustomSplit = false
    @State private var partner1Share: Double = 50
    @State private var date = Date.now
    @FocusState private var amountFocused: Bool

    private var isEditing: Bool { existingExpense != nil }

    private var parsedAmount: Decimal? {
        let normalized = amountText
            .replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        return Decimal(string: normalized)
    }

    private var hasInvalidAmount: Bool {
        !amountText.isEmpty && (parsedAmount == nil || parsedAmount! <= 0)
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && (parsedAmount ?? 0) > 0
    }

    private var activePaidByColor: Color {
        paidBy == .partner1 ? .partner1 : .partner2
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // ── Montant (champ XL central) ───────────────────────
                    amountCard

                    // ── Titre ────────────────────────────────────────────
                    sectionCard("Libellé") {
                        TextField("Restaurant, hôtel, courses…", text: $title)
                            .font(.system(.body, design: .rounded))
                            .submitLabel(.next)
                    }

                    // ── Payé par ─────────────────────────────────────────
                    sectionCard("Payé par") {
                        HStack(spacing: 10) {
                            paidByButton(.partner1, name: project.partner1Name)
                            paidByButton(.partner2, name: project.partner2Name)
                        }
                    }

                    // ── Répartition ──────────────────────────────────────
                    sectionCard("Répartition") {
                        VStack(spacing: 14) {
                            splitSelector
                            if isCustomSplit {
                                splitSlider
                            }
                        }
                    }

                    // ── Date ─────────────────────────────────────────────
                    sectionCard("Date") {
                        DatePicker("", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 32)
            }
            .background(Color.warmBackground.ignoresSafeArea())
            .navigationTitle(isEditing ? "Modifier" : "Nouvelle dépense")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.large])
            .presentationCornerRadius(24)
            .presentationDragIndicator(.visible)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                        .font(.system(.body, design: .rounded))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Enregistrer" : "Ajouter") { saveExpense() }
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .disabled(!isFormValid)
                }
            }
            .onAppear {
                prefillIfEditing()
                if !isEditing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        amountFocused = true
                    }
                }
            }
        }
    }

    // MARK: - Champ montant XL

    private var amountCard: some View {
        VStack(spacing: 6) {
            Text("Montant")
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("€")
                    .font(.system(size: 32, weight: .light, design: .rounded))
                    .foregroundStyle(activePaidByColor.opacity(0.7))

                TextField("0,00", text: $amountText)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(amountText.isEmpty ? Color.secondary.opacity(0.4) : activePaidByColor)
                    .keyboardType(.decimalPad)
                    .focused($amountFocused)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
                    .animation(.spring(response: 0.3), value: activePaidByColor)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .onTapGesture { amountFocused = true }

            if hasInvalidAmount {
                Label("Montant invalide", systemImage: "exclamationmark.triangle.fill")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 4)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.spring(response: 0.3), value: hasInvalidAmount)
    }

    // MARK: - Sélecteur payeur

    private func paidByButton(_ role: PartnerRole, name: String) -> some View {
        let color: Color = role == .partner1 ? .partner1 : .partner2
        let isSelected = paidBy == role
        return Button {
            withAnimation(.spring(response: 0.3)) { paidBy = role }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            VStack(spacing: 8) {
                // Avatar initial
                ZStack {
                    Circle()
                        .fill(isSelected ? color.gradient : Color.secondary.opacity(0.12).gradient)
                        .shadow(color: isSelected ? color.opacity(0.35) : .clear, radius: 6, y: 3)
                    Text(String(name.prefix(1)).uppercased())
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? .white : Color.secondary)
                }
                .frame(width: 50, height: 50)

                Text(name)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? AnyShapeStyle(color.opacity(0.08)) : cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? color.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3), value: isSelected)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Répartition

    private var splitSelector: some View {
        HStack(spacing: 0) {
            splitTab(label: "50 / 50", isSelected: !isCustomSplit) {
                withAnimation(.spring(response: 0.3)) { isCustomSplit = false }
            }
            splitTab(label: "Personnalisé", isSelected: isCustomSplit) {
                withAnimation(.spring(response: 0.3)) { isCustomSplit = true }
            }
        }
        .background(Color.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func splitTab(label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(isSelected ? Color.accentPrimary : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 11))
                .padding(2)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }

    private var splitSlider: some View {
        VStack(spacing: 10) {
            // Labels %
            HStack {
                Text(project.partner1Name)
                    .foregroundStyle(Color.partner1)
                Spacer()
                Text("\(Int(partner1Share))% · \(Int(100 - partner1Share))%")
                    .foregroundStyle(Color.accentPrimary)
                Spacer()
                Text(project.partner2Name)
                    .foregroundStyle(Color.partner2)
            }
            .font(.system(.caption, design: .rounded))
            .fontWeight(.medium)

            // Slider avec fond dégradé
            ZStack {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.partner1.opacity(0.25), .partner2.opacity(0.25)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 6)
                Slider(value: $partner1Share, in: 0...100, step: 5)
                    .tint(Color.accentPrimary)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionCard<Content: View>(_ title: String, @ViewBuilder content: @escaping () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .kerning(0.5)
            content()
                .padding(16)
                .background(cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var cardBg: AnyShapeStyle {
        colorScheme == .dark
            ? AnyShapeStyle(Color(.secondarySystemGroupedBackground))
            : AnyShapeStyle(Color.cardBackground)
    }

    // MARK: - Logique

    private func prefillIfEditing() {
        guard let expense = existingExpense else { return }
        title = expense.title
        amountText = expense.amount.description
        paidBy = expense.paidBy
        date = expense.date
        switch expense.splitRatio {
        case .equal:
            isCustomSplit = false
            partner1Share = 50
        case .custom(let p1, _):
            isCustomSplit = true
            partner1Share = Double(truncating: p1 as NSDecimalNumber)
        }
    }

    private func saveExpense() {
        guard let amount = parsedAmount, amount > 0 else { return }
        let splitRatio: SplitRatio = isCustomSplit
            ? .custom(partner1Share: Decimal(Int(partner1Share)), partner2Share: Decimal(Int(100 - partner1Share)))
            : .equal

        if let expense = existingExpense {
            expense.title = title.trimmingCharacters(in: .whitespaces)
            expense.amount = amount
            expense.paidBy = paidBy
            expense.splitRatio = splitRatio
            expense.date = date
        } else {
            let expense = Expense(
                title: title.trimmingCharacters(in: .whitespaces),
                amount: amount,
                paidBy: paidBy,
                splitRatio: splitRatio,
                date: date
            )
            expense.project = project
            modelContext.insert(expense)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        dismiss()
    }
}

#Preview {
    AddExpenseView(project: SampleData.sampleProject)
        .modelContainer(SampleData.container)
}
