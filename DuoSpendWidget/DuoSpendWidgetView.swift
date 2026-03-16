import SwiftUI
import WidgetKit

/// Vue du widget — supporte small, medium et large
struct DuoSpendWidgetView: View {
    let entry: DuoSpendEntry
    @Environment(\.widgetFamily) var family

    // Couleurs hardcodées (les named colors de l'app ne sont pas accessibles depuis le widget)
    private let partner1Color = Color(red: 0x2E / 255, green: 0x80 / 255, blue: 0xF2 / 255)
    private let partner2Color = Color(red: 0xF2 / 255, green: 0x5A / 255, blue: 0x7E / 255)
    private let accentColor = Color(red: 0x6C / 255, green: 0x63 / 255, blue: 0xFF / 255)

    var body: some View {
        switch family {
        case .systemSmall:  smallWidget
        case .systemMedium: mediumWidget
        case .systemLarge:  largeWidget
        default:            smallWidget
        }
    }

    // MARK: - Small

    private var smallWidget: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.projectName)
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            balanceText

            Spacer()

            Text("\(entry.totalSpent) dep.")
                .font(.system(.caption2, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetURL(URL(string: "duospend://project"))
    }

    // MARK: - Medium

    private var mediumWidget: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.projectName)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Text(entry.totalSpent)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            balanceText

            contributionBar
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetURL(URL(string: "duospend://project"))
    }

    // MARK: - Large

    private var largeWidget: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.projectName)
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Text(entry.totalSpent)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            balanceText

            contributionBar

            if !entry.recentExpenses.isEmpty {
                Divider()

                Text("Dernieres depenses")
                    .font(.system(.caption2, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                ForEach(entry.recentExpenses) { expense in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(expense.isPartner1 ? partner1Color : partner2Color)
                            .frame(width: 8, height: 8)

                        Text(expense.title)
                            .font(.system(.caption, design: .rounded))
                            .lineLimit(1)

                        Spacer()

                        Text(expense.amount)
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(expense.isPartner1 ? partner1Color : partner2Color)
                    }
                }
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetURL(URL(string: "duospend://project"))
    }

    // MARK: - Composants partagés

    private var balanceText: some View {
        Group {
            switch entry.balanceStatus {
            case .balanced:
                Text("Equilibre")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.green)

            case .owes(let debtor, let creditor, let amount):
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(debtor) doit")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(amount)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundStyle(accentColor)
                    Text("a \(creditor)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var contributionBar: some View {
        let total = entry.partner1Spent + entry.partner2Spent
        let p1Fraction = total > 0
            ? Double(truncating: entry.partner1Spent as NSDecimalNumber)
                / Double(truncating: total as NSDecimalNumber)
            : 0.5

        return VStack(spacing: 4) {
            GeometryReader { geo in
                HStack(spacing: 2) {
                    Capsule()
                        .fill(partner1Color)
                        .frame(width: max(geo.size.width * p1Fraction - 1, 4))
                    Capsule()
                        .fill(partner2Color)
                }
            }
            .frame(height: 6)
            .clipShape(Capsule())

            HStack {
                Text(entry.partner1Name)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(partner1Color)
                Spacer()
                Text(entry.partner2Name)
                    .font(.system(size: 9, design: .rounded))
                    .foregroundStyle(partner2Color)
            }
        }
    }
}

#Preview(as: .systemSmall) {
    DuoSpendWidget()
} timeline: {
    DuoSpendEntry.placeholder
}

#Preview(as: .systemMedium) {
    DuoSpendWidget()
} timeline: {
    DuoSpendEntry.placeholder
}

#Preview(as: .systemLarge) {
    DuoSpendWidget()
} timeline: {
    DuoSpendEntry.placeholder
}
