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

    // Noms nominatifs : l'utilisateur voit immédiatement qui est à quelle part.
    private var splitLabel: String {
        switch expense.splitRatio {
        case .equal:
            return "\(partner1Name) 50 % · \(partner2Name) 50 %"
        case .custom(let p1, let p2):
            let p1Int = Int(truncating: p1 as NSDecimalNumber)
            let p2Int = Int(truncating: p2 as NSDecimalNumber)
            return "\(partner1Name) \(p1Int) % · \(partner2Name) \(p2Int) %"
        }
    }

    private var isCustomSplit: Bool {
        switch expense.splitRatio {
        case .equal: return false
        case .custom(let p1, let p2):
            // Masquer le badge si les valeurs sont égales à 50/50 ou 0/100 (données corrompues)
            let p1Int = Int(truncating: p1 as NSDecimalNumber)
            let p2Int = Int(truncating: p2 as NSDecimalNumber)
            return p1Int != p2Int && p1Int > 0 && p2Int > 0
        }
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
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
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

#if DEBUG
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
#endif
