import SwiftUI

/// Card resumant un projet dans la liste d'accueil
struct ProjectCard: View {
    let project: Project

    private var balance: BalanceResult {
        BalanceCalculator.calculate(expenses: project.expenses)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text(project.emoji)
                    .font(.system(size: 28))
                    .frame(width: 48, height: 48)
                    .background(Color.accentPrimary.opacity(0.15))
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Color.accentPrimary.opacity(0.2), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                    Text("\(balance.totalSpent.formattedCurrency) d\u{00E9}pens\u{00E9}s")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            ProgressView(
                value: Double(truncating: balance.totalSpent as NSDecimalNumber),
                total: Double(truncating: project.budget as NSDecimalNumber)
            )
            .tint(Color.accentPrimary)

            balanceLabel
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.accentPrimary.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    @ViewBuilder
    private var balanceLabel: some View {
        switch balance.status {
        case .partner2OwesPartner1(let amount):
            Label(
                "\(project.partner2Name) doit \(amount.formattedCurrency) \u{00E0} \(project.partner1Name)",
                systemImage: "arrow.right"
            )
            .foregroundStyle(Color.partner1)
        case .partner1OwesPartner2(let amount):
            Label(
                "\(project.partner1Name) doit \(amount.formattedCurrency) \u{00E0} \(project.partner2Name)",
                systemImage: "arrow.right"
            )
            .foregroundStyle(Color.partner2)
        case .balanced:
            Label("\u{00C9}quilibre", systemImage: "checkmark.circle.fill")
                .foregroundStyle(Color.successGreen)
        }
    }
}

#Preview {
    ProjectCard(project: SampleData.sampleProject)
        .padding()
        .background(Color.warmBackground)
        .modelContainer(SampleData.container)
}
