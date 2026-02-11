import SwiftUI

/// Sheet d'ajout ou d'édition d'une dépense
struct AddExpenseView: View {
    let project: Project
    var existingExpense: Expense?

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amountText = ""
    @State private var paidBy: PartnerRole = .partner1
    @State private var isCustomSplit = false
    @State private var partner1Share: Double = 50
    @State private var date = Date.now

    private var isEditing: Bool { existingExpense != nil }

    private var parsedAmount: Decimal? {
        Decimal(string: amountText.replacingOccurrences(of: ",", with: "."))
    }

    private var hasInvalidAmount: Bool {
        !amountText.isEmpty && (parsedAmount == nil || parsedAmount! <= 0)
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
            && (parsedAmount ?? 0) > 0
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Dépense") {
                    TextField("Restaurant, hôtel, courses…", text: $title)
                    TextField("0,00 €", text: $amountText)
                        .keyboardType(.decimalPad)
                    if hasInvalidAmount {
                        Text("Le montant doit être supérieur à 0.")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Payé par") {
                    HStack(spacing: 12) {
                        paidByButton(
                            role: .partner1,
                            name: project.partner1Name,
                            color: Color.partner1
                        )
                        paidByButton(
                            role: .partner2,
                            name: project.partner2Name,
                            color: Color.partner2
                        )
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }

                Section("Répartition") {
                    Picker("Répartition", selection: $isCustomSplit) {
                        Text("50 / 50").tag(false)
                        Text("Custom").tag(true)
                    }
                    .pickerStyle(.segmented)

                    if isCustomSplit {
                        VStack(spacing: 8) {
                            Slider(value: $partner1Share, in: 0...100, step: 5)
                                .tint(Color.accentPrimary)
                            HStack {
                                Text("\(project.partner1Name) : \(Int(partner1Share))%")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.partner1)
                                Spacer()
                                Text("\(project.partner2Name) : \(Int(100 - partner1Share))%")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color.partner2)
                            }
                        }
                    }
                }

                Section("Date") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle(isEditing ? "Modifier la dépense" : "Nouvelle dépense")
            .navigationBarTitleDisplayMode(.inline)
            .presentationDetents([.large])
            .presentationCornerRadius(20)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Enregistrer" : "Ajouter") { saveExpense() }
                        .disabled(!isFormValid)
                }
            }
            .onAppear { prefillIfEditing() }
        }
    }

    @ViewBuilder
    private func paidByButton(role: PartnerRole, name: String, color: Color) -> some View {
        let isSelected = paidBy == role
        Button {
            withAnimation(.spring(response: 0.3)) { paidBy = role }
        } label: {
            Text(name)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(isSelected ? .semibold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? color.opacity(0.15) : Color(.systemGray6))
                .foregroundStyle(isSelected ? color : .secondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(isSelected ? color : Color.clear, lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
    }

    private func prefillIfEditing() {
        guard let expense = existingExpense else { return }
        title = expense.title
        amountText = "\(expense.amount)"
        paidBy = expense.paidBy
        date = expense.date

        switch expense.splitRatio {
        case .equal:
            isCustomSplit = false
            partner1Share = 50
        case .custom(let p1Share, _):
            isCustomSplit = true
            partner1Share = Double(truncating: p1Share as NSDecimalNumber)
        }
    }

    private func saveExpense() {
        guard let amount = Decimal(
            string: amountText.replacingOccurrences(of: ",", with: ".")
        ) else { return }

        let splitRatio: SplitRatio
        if isCustomSplit {
            let p1 = Int(partner1Share)
            splitRatio = .custom(
                partner1Share: Decimal(p1),
                partner2Share: Decimal(100 - p1)
            )
        } else {
            splitRatio = .equal
        }

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
