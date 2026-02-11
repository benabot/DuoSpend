import Foundation

/// Résultat du calcul de balance pour un projet
struct BalanceResult: Sendable {
    let totalSpent: Decimal
    let partner1Spent: Decimal
    let partner2Spent: Decimal
    let partner1Share: Decimal
    let partner2Share: Decimal
    let netBalance: Decimal
    let status: BalanceStatus
}

/// Statut de la balance entre les deux partenaires
enum BalanceStatus: Equatable, Sendable {
    case partner2OwesPartner1(Decimal)
    case partner1OwesPartner2(Decimal)
    case balanced
}

/// Calculateur de balance — logique métier pure, sans dépendance SwiftUI/SwiftData
enum BalanceCalculator {

    /// Calcule la balance d'un projet à partir de ses dépenses
    static func calculate(expenses: [Expense]) -> BalanceResult {
        var totalSpent: Decimal = 0
        var partner1Spent: Decimal = 0
        var partner2Spent: Decimal = 0
        var partner1Share: Decimal = 0
        var partner2Share: Decimal = 0
        var netBalance: Decimal = 0

        for expense in expenses {
            let amount = expense.amount
            totalSpent += amount

            let p1Part = amount * expense.splitRatio.partner1Fraction
            let p2Part = amount * expense.splitRatio.partner2Fraction

            partner1Share += p1Part
            partner2Share += p2Part

            switch expense.paidBy {
            case .partner1:
                partner1Spent += amount
                netBalance += p2Part
            case .partner2:
                partner2Spent += amount
                netBalance -= p1Part
            }
        }

        let status: BalanceStatus
        if netBalance > 0 {
            status = .partner2OwesPartner1(netBalance)
        } else if netBalance < 0 {
            status = .partner1OwesPartner2(abs(netBalance))
        } else {
            status = .balanced
        }

        return BalanceResult(
            totalSpent: totalSpent,
            partner1Spent: partner1Spent,
            partner2Spent: partner2Spent,
            partner1Share: partner1Share,
            partner2Share: partner2Share,
            netBalance: netBalance,
            status: status
        )
    }
}
