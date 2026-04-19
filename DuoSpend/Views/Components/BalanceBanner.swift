import SwiftUI

/// Encart principal affichant qui doit combien à qui.
///
/// Affiche une phrase non ambiguë ("X doit rembourser Y"), le montant,
/// puis un mini-tableau avancé/dû qui permet à l'utilisateur de vérifier
/// le calcul sans avoir à le faire mentalement.
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
                    debtor: partner2Name,   creditor: partner1Name,   amount: amount,
                    debtorPaid: balance.partner2Paid, debtorDue: balance.partner2Due,
                    creditorPaid: balance.partner1Paid, creditorDue: balance.partner1Due
                )
            case .partner1OwesPartner2(let amount):
                settlementContent(
                    debtor: partner1Name,   creditor: partner2Name,   amount: amount,
                    debtorPaid: balance.partner1Paid, debtorDue: balance.partner1Due,
                    creditorPaid: balance.partner2Paid, creditorDue: balance.partner2Due
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
        amount: Decimal,
        debtorPaid: Decimal,   debtorDue: Decimal,
        creditorPaid: Decimal, creditorDue: Decimal
    ) -> some View {
        // Phrase principale — sens explicite, non ambigu
        (Text(debtor).fontWeight(.bold)
            + Text(LocalizedStringKey(" doit rembourser "))
            + Text(creditor).fontWeight(.bold))
            .font(.system(.subheadline, design: .rounded))
            .multilineTextAlignment(.center)
            .foregroundStyle(.white.opacity(0.9))

        // Montant central
        Text(amount.formattedCurrency)
            .font(.system(size: 52, weight: .bold, design: .rounded))
            .contentTransition(.numericText())
            .shadow(color: .black.opacity(0.12), radius: 2, y: 2)

        // Mini-tableau avancé / dû — montre pourquoi ce montant est correct
        VStack(spacing: 6) {
            Rectangle()
                .fill(.white.opacity(0.25))
                .frame(height: 0.5)
            detailRow(name: debtor,   paid: debtorPaid,   due: debtorDue)
            detailRow(name: creditor, paid: creditorPaid, due: creditorDue)
        }
        .padding(.top, 2)
    }

    private func detailRow(name: String, paid: Decimal, due: Decimal) -> some View {
        HStack(spacing: 0) {
            Text(name)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            statCell(value: paid, label: "avancé")
            statCell(value: due,  label: "dû")
        }
        .font(.system(.caption, design: .rounded))
        .foregroundStyle(.white.opacity(0.85))
    }

    private func statCell(value: Decimal, label: LocalizedStringKey) -> some View {
        VStack(alignment: .trailing, spacing: 1) {
            Text(value.formattedCurrency)
                .fontWeight(.medium)
                .monospacedDigit()
            Text(label)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(width: 82, alignment: .trailing)
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

#Preview {
    BalanceBanner(
        balance: BalanceCalculator.calculate(expenses: SampleData.sampleExpenses),
        partner1Name: "Marie",
        partner2Name: "Thomas"
    )
    .modelContainer(SampleData.container)
}
