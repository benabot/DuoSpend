import Foundation

/// Résultat du calcul de balance pour un projet.
///
/// Convention de signe pour `partner1Net` / `partner2Net` :
///   - positif → le partenaire est créancier (il a avancé plus que sa part)
///   - négatif → le partenaire est débiteur (il n'a pas assez avancé)
struct BalanceResult: Sendable {
    /// Somme de toutes les dépenses
    let totalSpent: Decimal
    /// Argent effectivement avancé par chaque partenaire
    let partner1Paid: Decimal
    let partner2Paid: Decimal
    /// Part réelle à supporter selon les splits de chaque dépense
    let partner1Due: Decimal
    let partner2Due: Decimal
    /// Solde net = payé − dû  (positif = créancier, négatif = débiteur)
    let partner1Net: Decimal
    let partner2Net: Decimal
    let status: BalanceStatus

    // MARK: - Rétrocompatibilité

    var partner1Spent: Decimal { partner1Paid }
    var partner2Spent: Decimal { partner2Paid }
    var partner1Share: Decimal { partner1Due }
    var partner2Share: Decimal { partner2Due }
    /// Solde de partner1 (positif = créancier). Identique à `partner1Net`.
    var netBalance: Decimal { partner1Net }
}

/// Statut de la balance entre les deux partenaires
enum BalanceStatus: Equatable, Sendable {
    case partner2OwesPartner1(Decimal)
    case partner1OwesPartner2(Decimal)
    case balanced
}

/// Calculateur de balance — logique métier pure, sans dépendance SwiftUI/SwiftData
enum BalanceCalculator {

    /// Calcule la balance d'un projet à partir de ses dépenses.
    ///
    /// **Stratégie d'arrondi :**
    /// - `p1Due` est arrondi à 2 décimales (centimes) en mode bancaire (`.plain`).
    /// - `p2Due = amount − p1Due` (reste exact) garantit `p1Due + p2Due = amount`.
    ///
    /// **Invariant vérifié à l'exécution :** `|partner1Net + partner2Net| < 0,01 €`
    static func calculate(expenses: [Expense]) -> BalanceResult {
        var totalSpent:   Decimal = 0
        var partner1Paid: Decimal = 0
        var partner2Paid: Decimal = 0
        var partner1Due:  Decimal = 0
        var partner2Due:  Decimal = 0

        for expense in expenses {
            let amount = expense.amount
            totalSpent += amount

            let p1Due = roundToEuroCents(amount * expense.splitRatio.partner1Fraction)
            let p2Due = amount - p1Due  // reste exact → p1Due + p2Due = amount

            partner1Due += p1Due
            partner2Due += p2Due

            switch expense.paidBy {
            case .partner1: partner1Paid += amount
            case .partner2: partner2Paid += amount
            }
        }

        let partner1Net = partner1Paid - partner1Due
        let partner2Net = partner2Paid - partner2Due

        let status: BalanceStatus
        if partner1Net > 0 {
            status = .partner2OwesPartner1(partner1Net)
        } else if partner1Net < 0 {
            status = .partner1OwesPartner2(abs(partner1Net))
        } else {
            status = .balanced
        }

        return BalanceResult(
            totalSpent: totalSpent,
            partner1Paid: partner1Paid,
            partner2Paid: partner2Paid,
            partner1Due: partner1Due,
            partner2Due: partner2Due,
            partner1Net: partner1Net,
            partner2Net: partner2Net,
            status: status
        )
    }

    // MARK: - Arrondi monétaire

    /// Arrondit un montant à 2 décimales en mode bancaire (demi-au-plus-proche).
    private static func roundToEuroCents(_ amount: Decimal) -> Decimal {
        var input = amount
        var result = Decimal()
        NSDecimalRound(&result, &input, 2, .plain)
        return result
    }
}
