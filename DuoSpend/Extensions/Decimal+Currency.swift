import Foundation

extension Decimal {
    /// Formate en devise EUR selon la locale active de l'app.
    var formattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = .autoupdatingCurrent
        return formatter.string(from: self as NSDecimalNumber) ?? "€0.00"
    }
}
