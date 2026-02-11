import Foundation

extension Decimal {
    /// Formate en devise EUR localisée (ex: "1 234,56 €" en fr_FR)
    var formattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "EUR"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: self as NSDecimalNumber) ?? "0,00 €"
    }
}
