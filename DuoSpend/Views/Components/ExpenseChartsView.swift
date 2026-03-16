import SwiftUI
import Charts

/// Graphiques visuels des dépenses : répartition par partenaire + évolution dans le temps
struct ExpenseChartsView: View {
    let expenses: [Expense]
    let partner1Name: String
    let partner2Name: String
    let balance: BalanceResult

    @Environment(\.colorScheme) private var colorScheme

    /// Points cumulés pour le graphique d'évolution
    private var cumulativeData: [(date: Date, total: Double)] {
        let sorted = expenses.sorted { $0.date < $1.date }
        var cumulative: Double = 0
        return sorted.map { expense in
            cumulative += Double(truncating: expense.amount as NSDecimalNumber)
            return (date: expense.date, total: cumulative)
        }
    }

    var body: some View {
        TabView {
            barChart
            lineChart
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 300)
    }

    // MARK: - Répartition par partenaire

    private var barChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Qui a payé quoi ?", systemImage: "chart.bar.fill")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentPrimary)

            Chart {
                BarMark(
                    x: .value("Partenaire", partner1Name),
                    y: .value("Montant", Double(truncating: balance.partner1Spent as NSDecimalNumber))
                )
                .foregroundStyle(Color.partner1.gradient)
                .annotation(position: .top) {
                    Text(balance.partner1Spent.formattedCurrency)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.partner1)
                }

                BarMark(
                    x: .value("Partenaire", partner2Name),
                    y: .value("Montant", Double(truncating: balance.partner2Spent as NSDecimalNumber))
                )
                .foregroundStyle(Color.partner2.gradient)
                .annotation(position: .top) {
                    Text(balance.partner2Spent.formattedCurrency)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.partner2)
                }
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(Decimal(amount).formattedCurrency)
                                .font(.system(.caption2, design: .rounded))
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: shadowColor, radius: 10, y: 4)
    }

    // MARK: - Évolution dans le temps

    private var lineChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Évolution des dépenses", systemImage: "chart.line.uptrend.xyaxis")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundStyle(Color.accentPrimary)

            Chart(cumulativeData, id: \.date) { point in
                AreaMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Total", point.total)
                )
                .foregroundStyle(Color.accentPrimary.opacity(0.1))
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Total", point.total)
                )
                .foregroundStyle(Color.accentPrimary)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5))
            }
            .frame(height: 180)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(Decimal(amount).formattedCurrency)
                                .font(.system(.caption2, design: .rounded))
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: shadowColor, radius: 10, y: 4)
    }

    // MARK: - Helpers

    private var cardBg: some ShapeStyle {
        colorScheme == .dark
            ? AnyShapeStyle(Color(.secondarySystemGroupedBackground))
            : AnyShapeStyle(Color.cardBackground)
    }

    private var shadowColor: Color {
        colorScheme == .dark ? .black.opacity(0.25) : .black.opacity(0.06)
    }
}

#Preview {
    ScrollView {
        ExpenseChartsView(
            expenses: SampleData.sampleExpenses,
            partner1Name: "Marie",
            partner2Name: "Thomas",
            balance: BalanceCalculator.calculate(expenses: SampleData.sampleExpenses)
        )
        .padding(.horizontal)
    }
    .background(Color.warmBackground)
    .modelContainer(SampleData.container)
}
