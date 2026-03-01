import SwiftUI

/// Card résumant un projet dans la liste d'accueil
struct ProjectCard: View {
    let project: Project

    @Environment(\.colorScheme) private var colorScheme
    @State private var pressed = false

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

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // ── Header ──────────────────────────────────────────────
            HStack(spacing: 12) {
                // Emoji avec fond dégradé
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

                // Montant total + badge balance
                VStack(alignment: .trailing, spacing: 4) {
                    Text(balance.totalSpent.formattedCurrency)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(Color.accentPrimary)
                    balanceBadge
                }
            }

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
                Label(
                    "\(project.expenses.count) dépense\(project.expenses.count == 1 ? "" : "s")",
                    systemImage: "list.bullet"
                )
                .font(.system(.caption, design: .rounded))
                .foregroundStyle(.secondary)

                Spacer()

                // Mini avatars duo
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
        .scaleEffect(pressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: pressed)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: 50) { } onPressingChanged: { p in
            pressed = p
        }
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
            Circle()
                .fill(Color.partner1)
                .frame(width: 6, height: 6)
            Text(project.partner1Name)
                .foregroundStyle(Color.partner1)
            Text("·")
                .foregroundStyle(.tertiary)
            Circle()
                .fill(Color.partner2)
                .frame(width: 6, height: 6)
            Text(project.partner2Name)
                .foregroundStyle(Color.partner2)
        }
        .font(.system(.caption, design: .rounded))
        .fontWeight(.medium)
    }

    @ViewBuilder
    private var balanceBadge: some View {
        switch balance.status {
        case .balanced:
            Label("Équilibre", systemImage: "checkmark.circle.fill")
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(Color.successGreen)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.successGreen.opacity(0.12))
                .clipShape(Capsule())

        case .partner1OwesPartner2(let amount), .partner2OwesPartner1(let amount):
            let isP1 = {
                if case .partner1OwesPartner2 = balance.status { return true }
                return false
            }()
            Text("\(isP1 ? project.partner1Name : project.partner2Name) doit \(amount.formattedCurrency)")
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(isP1 ? Color.partner2 : Color.partner1)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background((isP1 ? Color.partner2 : Color.partner1).opacity(0.1))
                .clipShape(Capsule())
                .lineLimit(1)
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
