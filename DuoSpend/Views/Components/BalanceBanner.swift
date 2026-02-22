import SwiftUI

/// Encart principal affichant qui doit combien a qui
struct BalanceBanner: View {
    let balance: BalanceResult
    let partner1Name: String
    let partner2Name: String

    @State private var iconBounce = false

    var body: some View {
        VStack(spacing: 8) {
            switch balance.status {
            case .partner2OwesPartner1(let amount):
                duoHearts
                debtContent(from: partner2Name, fromColor: .partner2,
                            to: partner1Name,   toColor: .partner1,
                            amount: amount)
            case .partner1OwesPartner2(let amount):
                duoHearts
                debtContent(from: partner1Name, fromColor: .partner1,
                            to: partner2Name,   toColor: .partner2,
                            amount: amount)
            case .balanced:
                statusIcon(systemName: "checkmark.circle.fill", color: .white)
                Text("Vous \u{00EA}tes \u{00E0} l'\u{00E9}quilibre")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal)
        .background(backgroundGradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
        .padding(.horizontal)
        .onAppear { iconBounce = true }
    }

    @ViewBuilder
    private func statusIcon(systemName: String, color: Color) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 28))
            .foregroundStyle(color)
            .symbolEffect(.bounce, value: iconBounce)
    }

    /// Deux petits cœurs colorés représentant le duo, en version blanche (sur fond coloré)
    private var duoHearts: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.75))
                .offset(y: -2)
            Image(systemName: "heart.fill")
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.90))
                .offset(y: 2)
        }
        .symbolEffect(.bounce, value: iconBounce)
    }

    @ViewBuilder
    private func debtContent(
        from: String, fromColor: Color,
        to: String,   toColor: Color,
        amount: Decimal
    ) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(fromColor.opacity(0.35))
                .frame(width: 8, height: 8)
            Text(from)
                .fontWeight(.semibold)
            Image(systemName: "arrow.right")
                .font(.body)
                .phaseAnimator([false, true]) { content, phase in
                    content.offset(x: phase ? 3 : -1)
                } animation: { _ in
                    .easeInOut(duration: 0.8)
                }
            Circle()
                .fill(toColor.opacity(0.35))
                .frame(width: 8, height: 8)
            Text(to)
                .fontWeight(.semibold)
        }
        .font(.callout)
        .fontWeight(.semibold)
        Text(amount.formattedCurrency)
            .font(.system(size: 48, weight: .bold, design: .rounded))
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
