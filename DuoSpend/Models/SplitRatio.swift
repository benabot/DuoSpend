import Foundation

/// Ratio de répartition d'une dépense entre les deux partenaires
enum SplitRatio: Codable, Equatable {
    case equal
    case custom(partner1Share: Decimal, partner2Share: Decimal)

    /// Part du partenaire 1 (entre 0 et 1)
    var partner1Fraction: Decimal {
        switch self {
        case .equal:
            return Decimal(sign: .plus, exponent: -1, significand: 5) // 0.5
        case .custom(let p1Share, let p2Share):
            let total = p1Share + p2Share
            guard total > 0 else { return Decimal(sign: .plus, exponent: -1, significand: 5) }
            return p1Share / total
        }
    }

    /// Part du partenaire 2 (entre 0 et 1)
    var partner2Fraction: Decimal {
        1 - partner1Fraction
    }
}
