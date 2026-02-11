import Foundation
import SwiftData

/// Dépense individuelle liée à un projet
@Model
class Expense {
    var title: String
    var amount: Decimal
    var paidByRawValue: String
    var splitRatioData: Data?
    var category: String?
    var date: Date

    var project: Project?

    /// Accès typé au partenaire payeur
    var paidBy: PartnerRole {
        get { PartnerRole(rawValue: paidByRawValue) ?? .partner1 }
        set { paidByRawValue = newValue.rawValue }
    }

    /// Accès typé au ratio de répartition
    var splitRatio: SplitRatio {
        get {
            guard let data = splitRatioData,
                  let ratio = try? JSONDecoder().decode(SplitRatio.self, from: data)
            else { return .equal }
            return ratio
        }
        set {
            splitRatioData = try? JSONEncoder().encode(newValue)
        }
    }

    init(
        title: String,
        amount: Decimal,
        paidBy: PartnerRole,
        splitRatio: SplitRatio = .equal,
        category: String? = nil,
        date: Date = .now
    ) {
        self.title = title
        self.amount = amount
        self.paidByRawValue = paidBy.rawValue
        self.splitRatioData = try? JSONEncoder().encode(splitRatio)
        self.category = category
        self.date = date
    }
}
