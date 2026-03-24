import SwiftUI

/// Card résumant un projet dans la liste d'accueil
struct ProjectCard: View {
    let project: Project

    @Environment(\.colorScheme) private var colorScheme

    private var balance: BalanceResult {
        BalanceCalculator.calculate(expenses: project.expenses)
    }

    private var budgetFraction: Double {
        guard project.budget > 0 else { return 0 }
        let spent = Double(truncating: balance.totalSpent as NSDecimalNumber)
        let budget = Double(truncating: project.budget as NSDecimalNumber)
        return min(spent / budget, 1.0)
    }

    private var isOverBudget: Bool { balance.totalSpent > project.budget && project.budget > 0 }

    private var p1Fraction: Double {
        guard balance.totalSpent > 0 else { return 0.5 }
        return Double(truncating: balance.partner1Spent as NSDecimalNumber)
            / Double(truncating: balance.totalSpent as NSDecimalNumber)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // ── Header ──────────────────────────────────────────────
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.accentPrimary.opacity(0.18), Color.accentPrimary.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    Text(project.emoji)
                        .font(.system(size: 26))
                }
                .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 5) {
                    Text(project.name)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .lineLimit(1)
                    duoPartnerLabel
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(balance.totalSpent.formattedCurrency)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentPrimary)
                    Text("dépensé")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }

            // ── Balance (pleine largeur) ────────────────────────────
            balanceSection

            // ── Barre de budget ──────────────────────────────────────
            if project.budget > 0 {
                VStack(spacing: 5) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.secondary.opacity(colorScheme == .dark ? 0.2 : 0.12))
                            Capsule()
                                .fill(isOverBudget
                                      ? Color.red.gradient
                                      : Color.accentPrimary.gradient)
                                .frame(width: geo.size.width * budgetFraction)
                                .animation(.spring(duration: 0.6), value: budgetFraction)
                        }
                    }
                    .frame(height: 6)
                    .clipShape(Capsule())

                    HStack {
                        Text(isOverBudget ? "⚠ Budget dépassé" : "\(Int(budgetFraction * 100))% du budget")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(isOverBudget ? Color.red : Color.secondary)
                        Spacer()
                        Text(project.budget.formattedCurrency)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // ── Footer : nb dépenses ─────────────────────────────────
            HStack {
                Label("\(project.expenses.count) dépense", systemImage: "list.bullet")
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)

                Spacer()

                HStack(spacing: -6) {
                    miniAvatar(name: project.partner1Name, color: .partner1)
                    miniAvatar(name: project.partner2Name, color: .partner2)
                }
            }
        }
        .padding(18)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .shadow(
            color: colorScheme == .dark
                ? Color.black.opacity(0.3)
                : Color.accentPrimary.opacity(0.09),
            radius: 14,
            x: 0,
            y: 5
        )
        .contentShape(Rectangle())
    }

    // MARK: - Subviews

    private var cardBackground: some View {
        Group {
            if colorScheme == .dark {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(.secondarySystemGroupedBackground))
            } else {
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color.cardBackground)
            }
        }
    }

    private var duoPartnerLabel: some View {
        HStack(spacing: 4) {
            Text(project.partner1Name)
                .foregroundStyle(Color.partner1)
                .lineLimit(1)
            Text("&")
                .foregroundStyle(.tertiary)
            Text(project.partner2Name)
                .foregroundStyle(Color.partner2)
                .lineLimit(1)
        }
        .font(.system(.caption, design: .rounded))
        .fontWeight(.medium)
        .minimumScaleFactor(0.8)
    }

    // MARK: - Balance Section

    @ViewBuilder
    private var balanceSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            switch balance.status {
            case .balanced:
                Label("Équilibre", systemImage: "checkmark.circle.fill")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.successGreen)

            case .partner1OwesPartner2(let amount):
                balanceText(
                    debtor: project.partner1Name, debtorColor: .partner1,
                    creditor: project.partner2Name, creditorColor: .partner2,
                    amount: amount
                )

            case .partner2OwesPartner1(let amount):
                balanceText(
                    debtor: project.partner2Name, debtorColor: .partner2,
                    creditor: project.partner1Name, creditorColor: .partner1,
                    amount: amount
                )
            }

            // Mini barre de répartition bicolore
            if !project.expenses.isEmpty {
                GeometryReader { geo in
                    HStack(spacing: 1.5) {
                        Capsule()
                            .fill(Color.partner1)
                            .frame(width: max(geo.size.width * p1Fraction - 1, 4))
                        Capsule()
                            .fill(Color.partner2)
                    }
                    .animation(.spring(duration: 0.6), value: p1Fraction)
                }
                .frame(height: 5)
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(balanceBgColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func balanceText(debtor: String, debtorColor: Color, creditor: String, creditorColor: Color, amount: Decimal) -> some View {
        HStack(spacing: 4) {
            Text(debtor)
                .foregroundStyle(debtorColor)
                .fontWeight(.semibold)
            Text("doit")
                .foregroundStyle(.secondary)
            Text(amount.formattedCurrency)
                .fontWeight(.bold)
            Text("à")
                .foregroundStyle(.secondary)
            Text(creditor)
                .foregroundStyle(creditorColor)
                .fontWeight(.semibold)
        }
        .font(.system(.caption, design: .rounded))
        .lineLimit(1)
        .minimumScaleFactor(0.8)
    }

    private var balanceBgColor: Color {
        switch balance.status {
        case .balanced: Color.successGreen
        case .partner1OwesPartner2: Color.partner2
        case .partner2OwesPartner1: Color.partner1
        }
    }

    private func miniAvatar(name: String, color: Color) -> some View {
        Text(String(name.prefix(1)).uppercased())
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 22, height: 22)
            .background(color)
            .clipShape(Circle())
            .overlay(Circle().strokeBorder(Color.cardBackground, lineWidth: 1.5))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ProjectCard(project: SampleData.sampleProject)
        }
        .padding()
    }
    .background(Color.warmBackground)
    .modelContainer(SampleData.container)
}
