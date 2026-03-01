import SwiftUI

/// Ligne affichant une dépense dans la liste
struct ExpenseRow: View {
    let expense: Expense
    let partner1Name: String
    let partner2Name: String

    @Environment(\.colorScheme) private var colorScheme

    private var payerName: String {
        expense.paidBy == .partner1 ? partner1Name : partner2Name
    }

    private var payerColor: Color {
        expense.paidBy == .partner1 ? .partner1 : .partner2
    }

    private var payerInitial: String {
        String(payerName.prefix(1)).uppercased()
    }

    private var splitLabel: String {
        switch expense.splitRatio {
        case .equal: return "50/50"
        case .custom(let p1, let p2):
            return "\(Int(truncating: p1 as NSDecimalNumber))/\(Int(truncating: p2 as NSDecimalNumber))"
        }
    }

    private var isCustomSplit: Bool {
        if case .custom = expense.splitRatio { return true }
        return false
    }

    var body: some View {
        HStack(spacing: 13) {
            // Avatar payeur
            ZStack {
                Circle()
                    .fill(payerColor.gradient)
                    .shadow(color: payerColor.opacity(0.3), radius: 4, y: 2)
                Text(payerInitial)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
            .frame(width: 42, height: 42)

            // Titre + méta
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 5) {
                    Text(payerName)
                        .foregroundStyle(payerColor)
                        .fontWeight(.medium)

                    Text("·")
                        .foregroundStyle(.tertiary)

                    Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                        .foregroundStyle(.secondary)

                    if isCustomSplit {
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Text(splitLabel)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(Color.accentPrimary.opacity(0.1))
                            .foregroundStyle(Color.accentPrimary)
                            .clipShape(Capsule())
                    }
                }
                .font(.system(.caption, design: .rounded))
            }

            Spacer()

            // Montant
            Text(expense.amount.formattedCurrency)
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(payerColor)
                .monospacedDigit()
        }
        .padding(.vertical, 5)
        .contentShape(Rectangle())
    }
}

#Preview {
    List {
        ExpenseRow(
            expense: SampleData.sampleExpense,
            partner1Name: "Marie",
            partner2Name: "Thomas"
        )
        ExpenseRow(
            expense: SampleData.sampleExpense,
            partner1Name: "Marie",
            partner2Name: "Thomas"
        )
    }
    .modelContainer(SampleData.container)
}
