import SwiftUI

/// Encart principal affichant qui doit combien a qui.
///
/// Le bandeau reste volontairement compact: une phrase directe et le montant net.
struct BalanceBanner: View {
    let balance: BalanceResult
    let partner1Name: String
    let partner2Name: String

    @State private var glowPulse = false

    var body: some View {
        VStack(spacing: 12) {
            switch balance.status {
            case .partner2OwesPartner1(let amount):
                settlementContent(
                    debtor: partner2Name,
                    creditor: partner1Name,
                    amount: amount
                )
            case .partner1OwesPartner2(let amount):
                settlementContent(
                    debtor: partner1Name,
                    creditor: partner2Name,
                    amount: amount
                )
            case .balanced:
                balancedContent
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(bannerBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
        .padding(.horizontal)
        .onAppear { glowPulse = true }
    }

    // MARK: - Cas déséquilibre

    @ViewBuilder
    private func settlementContent(
        debtor: String,
        creditor: String,
        amount: Decimal
    ) -> some View {
        // Phrase principale — sens direct et naturel
        (Text(debtor).fontWeight(.bold)
            + Text(LocalizedStringKey(" doit "))
            + Text(amount.formattedCurrency).fontWeight(.bold)
            + Text(LocalizedStringKey(" à "))
            + Text(creditor).fontWeight(.bold))
            .font(.system(.headline, design: .rounded))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white.opacity(0.9))
            .minimumScaleFactor(0.85)

        // Montant net en evidence
        Text(amount.formattedCurrency)
            .font(.system(size: 52, weight: .bold, design: .rounded))
            .contentTransition(.numericText())
            .shadow(color: .black.opacity(0.12), radius: 2, y: 2)
    }

    // MARK: - Cas équilibre

    private var balancedContent: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.white)
            Text("Vous êtes à l'équilibre")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
            Text("\(balance.totalSpent.formattedCurrency) dépensés au total")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    // MARK: - Fond animé

    private var bannerBackground: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Ellipse()
                .fill(.white.opacity(glowPulse ? 0.10 : 0.05))
                .frame(width: 180, height: 100)
                .blur(radius: 24)
                .offset(x: -60, y: -30)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: glowPulse)
        }
    }

    private var gradientColors: [Color] {
        switch balance.status {
        case .partner2OwesPartner1: [Color.partner1, Color.partner1.opacity(0.65)]
        case .partner1OwesPartner2: [Color.partner2, Color.partner2.opacity(0.65)]
        case .balanced:             [Color.successGreen, Color.successGreen.opacity(0.7)]
        }
    }

    private var shadowColor: Color {
        switch balance.status {
        case .partner2OwesPartner1: Color.partner1.opacity(0.35)
        case .partner1OwesPartner2: Color.partner2.opacity(0.35)
        case .balanced:             Color.successGreen.opacity(0.35)
        }
    }
}

#if DEBUG
#Preview {
    BalanceBanner(
        balance: BalanceCalculator.calculate(expenses: SampleData.sampleExpenses),
        partner1Name: "Marie",
        partner2Name: "Thomas"
    )
    .modelContainer(SampleData.container)
}
#endif
