import SwiftUI
import Charts

/// Graphique d'évolution cumulative des dépenses dans le temps.
/// Affiché dans ProjectDetailView uniquement si le projet a ≥ 2 dépenses.
/// Le bar chart par partenaire est intentionnellement absent : la carte
/// "Contributions" existante couvre déjà cette information.
struct ExpenseChartsView: View {
    let expenses: [Expense]
    let partner1Name: String
    let partner2Name: String
    let balance: BalanceResult

    @Environment(\.colorScheme) private var colorScheme

    /// Points triés chronologiquement avec total cumulé
    private var cumulativeData: [(date: Date, total: Double)] {
        let sorted = expenses.sorted { $0.date < $1.date }
        var cumulative: Double = 0
        return sorted.map { expense in
            cumulative += Double(truncating: expense.amount as NSDecimalNumber)
            return (date: expense.date, total: cumulative)
        }
    }

    var body: some View {
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
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.accentPrimary.opacity(0.18), Color.accentPrimary.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Total", point.total)
                )
                .foregroundStyle(Color.accentPrimary)
                .interpolationMethod(.catmullRom)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

                PointMark(
                    x: .value("Date", point.date, unit: .day),
                    y: .value("Total", point.total)
                )
                .foregroundStyle(Color.accentPrimary)
                .symbolSize(30)
            }
            .frame(height: 160)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 4)) { value in
                    AxisValueLabel(format: .dateTime.day().month(.abbreviated))
                        .font(.system(.caption2, design: .rounded))
                    AxisGridLine()
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(Decimal(amount).formattedCurrency)
                                .font(.system(.caption2, design: .rounded))
                        }
                    }
                    AxisGridLine()
                }
            }

            // Montant final affiché sobrement sous le chart
            HStack {
                Spacer()
                Text("Total : \(balance.totalSpent.formattedCurrency)")
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
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
