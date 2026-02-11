import SwiftUI

/// Ligne affichant une dépense dans la liste
struct ExpenseRow: View {
    let expense: Expense
    let partner1Name: String
    let partner2Name: String

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
        case .equal:
            "50/50"
        case .custom(let p1, let p2):
            "\(Int(truncating: p1 as NSDecimalNumber))/\(Int(truncating: p2 as NSDecimalNumber))"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(payerInitial)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(payerColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(expense.title)
                    .font(.body)
                HStack(spacing: 6) {
                    Text("\(payerName) · \(expense.date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(splitLabel)
                        .font(.system(.caption2, design: .rounded))
                        .fontWeight(.medium)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentPrimary.opacity(0.1))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            Text(expense.amount.formattedCurrency)
                .font(.system(.body, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(payerColor)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ExpenseRow(
        expense: SampleData.sampleExpense,
        partner1Name: "Marie",
        partner2Name: "Thomas"
    )
    .modelContainer(SampleData.container)
}
