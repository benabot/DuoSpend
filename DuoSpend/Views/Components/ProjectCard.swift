import SwiftUI

/// Card résumant un projet dans la liste d'accueil
struct ProjectCard: View {
    let project: Project

    private var balance: BalanceResult {
        BalanceCalculator.calculate(expenses: project.expenses)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Text(project.emoji)
                    .font(.title)
                    .frame(width: 48, height: 48)
                    .background(Color.accentPrimary.opacity(0.12))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(project.name)
                        .font(.system(.headline, design: .rounded))
                    Text("\(balance.totalSpent.formattedCurrency) dépensés")
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
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }

    @ViewBuilder
    private var balanceLabel: some View {
        switch balance.status {
        case .partner2OwesPartner1(let amount):
            Label(
                "\(project.partner2Name) doit \(amount.formattedCurrency) à \(project.partner1Name)",
                systemImage: "arrow.right"
            )
            .foregroundStyle(Color.partner1)
        case .partner1OwesPartner2(let amount):
            Label(
                "\(project.partner1Name) doit \(amount.formattedCurrency) à \(project.partner2Name)",
                systemImage: "arrow.right"
            )
            .foregroundStyle(Color.partner2)
        case .balanced:
            Label("Équilibre", systemImage: "checkmark.circle.fill")
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
