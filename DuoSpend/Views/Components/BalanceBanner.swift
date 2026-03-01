import SwiftUI

/// Encart principal affichant qui doit combien à qui — version améliorée
struct BalanceBanner: View {
    let balance: BalanceResult
    let partner1Name: String
    let partner2Name: String

    @State private var iconBounce = false
    @State private var glowPulse = false

    var body: some View {
        VStack(spacing: 10) {
            switch balance.status {
            case .partner2OwesPartner1(let amount):
                duoHearts
                debtContent(
                    from: partner2Name, fromColor: .partner2,
                    to: partner1Name,   toColor: .partner1,
                    amount: amount
                )
                debtProgressBar(debtorIsPartner1: false, amount: amount)

            case .partner1OwesPartner2(let amount):
                duoHearts
                debtContent(
                    from: partner1Name, fromColor: .partner1,
                    to: partner2Name,   toColor: .partner2,
                    amount: amount
                )
                debtProgressBar(debtorIsPartner1: true, amount: amount)

            case .balanced:
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                    .symbolEffect(.bounce, value: iconBounce)
                Text("Vous \u{00EA}tes \u{00E0} l'\u{00E9}quilibre")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                Text("\(balance.totalSpent.formattedCurrency) d\u{00E9}pens\u{00E9}s au total")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.75))
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .background(
            ZStack {
                backgroundGradient
                // Halo de lumière animé en haut à gauche
                Ellipse()
                    .fill(.white.opacity(glowPulse ? 0.10 : 0.05))
                    .frame(width: 180, height: 100)
                    .blur(radius: 24)
                    .offset(x: -60, y: -30)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: glowPulse)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
        .padding(.horizontal)
        .onAppear {
            iconBounce = true
            glowPulse = true
        }
    }

    // MARK: - Subviews

    /// Deux petits cœurs représentant le duo
    private var duoHearts: some View {
        HStack(spacing: 4) {
            Image(systemName: "heart.fill")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.75))
                .offset(y: -2)
            Image(systemName: "heart.fill")
                .font(.system(size: 12))
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
        // Noms avec flèche animée
        HStack(spacing: 6) {
            Text(from)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
            Image(systemName: "arrow.right")
                .font(.body)
                .phaseAnimator([false, true]) { content, phase in
                    content.offset(x: phase ? 4 : 0)
                } animation: { _ in .easeInOut(duration: 0.9) }
            Text(to)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(0.2))
                .clipShape(Capsule())
        }
        .font(.callout)

        // Montant principal
        Text(amount.formattedCurrency)
            .font(.system(size: 52, weight: .bold, design: .rounded))
            .contentTransition(.numericText())
            .shadow(color: .black.opacity(0.12), radius: 2, y: 2)

        // Sous-texte contextuel
        Text("\u{00E0} rembourser")
            .font(.system(.caption, design: .rounded))
            .foregroundStyle(.white.opacity(0.7))
    }

    /// Barre de répartition visuelle des paiements
    @ViewBuilder
    private func debtProgressBar(debtorIsPartner1: Bool, amount: Decimal) -> some View {
        let total = balance.totalSpent
        if total > 0 {
        let p1Fraction = Double(truncating: balance.partner1Spent as NSDecimalNumber)
                       / Double(truncating: total as NSDecimalNumber)

        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.25))
                    Capsule()
                        .fill(.white.opacity(0.85))
                        .frame(width: geo.size.width * CGFloat(p1Fraction))
                        .animation(.spring(duration: 0.7), value: p1Fraction)
                    // Marqueur 50%
                    Rectangle()
                        .fill(.white.opacity(0.5))
                        .frame(width: 1.5)
                        .offset(x: geo.size.width / 2)
                }
            }
            .frame(height: 7)
            .clipShape(Capsule())

            HStack {
                Text(partner1Name)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
                Spacer()
                Text(partner2Name)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .padding(.top, 2)
        } // end if total > 0
    }

    // MARK: - Helpers

    private var backgroundGradient: LinearGradient {
        switch balance.status {
        case .partner2OwesPartner1:
            LinearGradient(
                colors: [Color.partner1, Color.partner1.opacity(0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .partner1OwesPartner2:
            LinearGradient(
                colors: [Color.partner2, Color.partner2.opacity(0.65)],
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

    private var shadowColor: Color {
        switch balance.status {
        case .partner2OwesPartner1: Color.partner1.opacity(0.35)
        case .partner1OwesPartner2: Color.partner2.opacity(0.35)
        case .balanced: Color.successGreen.opacity(0.35)
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
