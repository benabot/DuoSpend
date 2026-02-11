import SwiftUI

/// Encart principal affichant qui doit combien à qui
struct BalanceBanner: View {
    let balance: BalanceResult
    let partner1Name: String
    let partner2Name: String

    var body: some View {
        VStack(spacing: 8) {
            switch balance.status {
            case .partner2OwesPartner1(let amount):
                debtContent(from: partner2Name, to: partner1Name, amount: amount)
            case .partner1OwesPartner2(let amount):
                debtContent(from: partner1Name, to: partner2Name, amount: amount)
            case .balanced:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                Text("Vous êtes à l'équilibre")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal)
        .background(backgroundGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }

    @ViewBuilder
    private func debtContent(from: String, to: String, amount: Decimal) -> some View {
        HStack(spacing: 8) {
            Text(from)
                .fontWeight(.semibold)
            Image(systemName: "arrow.right")
                .font(.body)
                .phaseAnimator([false, true]) { content, phase in
                    content.offset(x: phase ? 3 : -1)
                } animation: { _ in
                    .easeInOut(duration: 0.8)
                }
            Text(to)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
        Text(amount.formattedCurrency)
            .font(.system(size: 42, weight: .bold, design: .rounded))
            .contentTransition(.numericText())
    }

    private var backgroundGradient: LinearGradient {
        switch balance.status {
        case .partner2OwesPartner1:
            LinearGradient(
                colors: [Color.partner1, Color.partner1.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .partner1OwesPartner2:
            LinearGradient(
                colors: [Color.partner2, Color.partner2.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .balanced:
            LinearGradient(
                colors: [Color.successGreen, Color.successGreen.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    BalanceBanner(
        balance: BalanceCalculator.calculate(expenses: SampleData.sampleProject.expenses),
        partner1Name: "Marie",
        partner2Name: "Thomas"
    )
    .modelContainer(SampleData.container)
}
