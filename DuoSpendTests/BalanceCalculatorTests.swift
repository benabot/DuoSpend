import Foundation
import Testing
@testable import DuoSpend

@Suite("BalanceCalculator")
struct BalanceCalculatorTests {

    // MARK: - Tests existants (inchangés)

    @Test("Scénario 50/50 simple")
    func equal5050() {
        let expenses = [
            Expense(title: "Restaurant", amount: 80, paidBy: .partner1),
            Expense(title: "Essence", amount: 60, paidBy: .partner2),
        ]

        let result = BalanceCalculator.calculate(expenses: expenses)

        #expect(result.totalSpent == 140)
        #expect(result.netBalance == 10)
        #expect(result.status == .partner2OwesPartner1(10))
    }

    @Test("Mix 50/50 et custom split")
    func mixedSplit() {
        let expenses = [
            Expense(title: "Restaurant", amount: 80, paidBy: .partner1),
            Expense(title: "Essence", amount: 60, paidBy: .partner2),
            Expense(
                title: "Hôtel",
                amount: 200,
                paidBy: .partner1,
                splitRatio: .custom(partner1Share: 70, partner2Share: 30)
            ),
        ]

        let result = BalanceCalculator.calculate(expenses: expenses)

        #expect(result.totalSpent == 340)
        #expect(result.netBalance == 70)
        #expect(result.status == .partner2OwesPartner1(70))
    }

    @Test("Équilibre parfait")
    func perfectBalance() {
        let expenses = [
            Expense(title: "Dîner", amount: 100, paidBy: .partner1),
            Expense(title: "Billets", amount: 100, paidBy: .partner2),
        ]

        let result = BalanceCalculator.calculate(expenses: expenses)

        #expect(result.netBalance == 0)
        #expect(result.status == .balanced)
    }

    @Test("Une seule dépense custom")
    func singleCustomExpense() {
        let expenses = [
            Expense(
                title: "Location voiture",
                amount: 300,
                paidBy: .partner2,
                splitRatio: .custom(partner1Share: 60, partner2Share: 40)
            ),
        ]

        let result = BalanceCalculator.calculate(expenses: expenses)

        // P2 a payé 300€, part P1 = 180€, donc P1 doit 180€ à P2
        #expect(result.status == .partner1OwesPartner2(180))
    }

    @Test("Aucune dépense")
    func noExpenses() {
        let result = BalanceCalculator.calculate(expenses: [])

        #expect(result.totalSpent == 0)
        #expect(result.status == .balanced)
    }

    // MARK: - Nouveaux tests

    /// Cas de l'énoncé : 30/70 avec deux payeurs différents.
    /// Vérifie que le sens du remboursement est correct même quand
    /// les montants payés ne reflètent pas les parts dues.
    @Test("Énoncé 30/70 — deux payeurs")
    func customSplit3070TwoPayors() {
        // p1 = Toto, p2 = Marie
        let expenses = [
            Expense(title: "Dépense A", amount: 66, paidBy: .partner1,
                    splitRatio: .custom(partner1Share: 30, partner2Share: 70)),
            Expense(title: "Dépense B", amount: 44, paidBy: .partner2,
                    splitRatio: .custom(partner1Share: 30, partner2Share: 70)),
        ]

        let result = BalanceCalculator.calculate(expenses: expenses)

        // Toto payé 66, doit 33 (30% de 110) → net +33 (créancier)
        // Marie payé 44, doit 77 (70% de 110) → net −33 (débitrice)
        #expect(result.totalSpent == 110)
        #expect(result.partner1Due == 33)
        #expect(result.partner2Due == 77)
        #expect(result.partner1Net == 33)
        #expect(result.partner2Net == -33)
        #expect(result.status == .partner2OwesPartner1(33))

        // Invariant : somme des parts dues = total
        #expect(result.partner1Due + result.partner2Due == result.totalSpent)
    }

    /// Un seul partenaire paie tout — l'autre doit rembourser la moitié.
    @Test("Un seul payeur paie tout")
    func singlePayorAll() {
        let expenses = [
            Expense(title: "Vacances", amount: 500, paidBy: .partner1),
        ]

        let result = BalanceCalculator.calculate(expenses: expenses)

        #expect(result.totalSpent == 500)
        #expect(result.partner1Due == 250)
        #expect(result.partner2Due == 250)
        #expect(result.partner1Net == 250)
        #expect(result.partner2Net == -250)
        #expect(result.status == .partner2OwesPartner1(250))
    }

    /// Vérifie la stratégie d'arrondi : p2Due = amount − p1Due
    /// garantit que la somme des parts = montant exact de la dépense.
    @Test("Arrondi centimes — split 33/67")
    func roundingCents() {
        let expenses = [
            Expense(title: "Facture", amount: 10, paidBy: .partner1,
                    splitRatio: .custom(partner1Share: 33, partner2Share: 67)),
        ]

        let result = BalanceCalculator.calculate(expenses: expenses)

        // 10 × 0,33 = 3,30 ; reste = 6,70
        #expect(result.partner1Due == Decimal(string: "3.30")!)
        #expect(result.partner2Due == Decimal(string: "6.70")!)
        // Invariant fondamental
        #expect(result.partner1Due + result.partner2Due == 10)
        #expect(result.status == .partner2OwesPartner1(Decimal(string: "6.70")!))
    }

    /// Cas contre-intuitif : Marie paie 100€ et Toto seulement 30€,
    /// mais c'est quand même Marie qui doit rembourser Toto
    /// parce que sa part contractuelle (90%) dépasse ce qu'elle a avancé.
    @Test("Remboursement contre-intuitif — le plus gros payeur reste débiteur")
    func counterIntuitiveSettlement() {
        let expenses = [
            Expense(title: "A", amount: 30, paidBy: .partner1,
                    splitRatio: .custom(partner1Share: 10, partner2Share: 90)),
            Expense(title: "B", amount: 100, paidBy: .partner2,
                    splitRatio: .custom(partner1Share: 10, partner2Share: 90)),
        ]

        let result = BalanceCalculator.calculate(expenses: expenses)

        // Toto payé 30, doit 13 (10% de 130) → net +17 (créancier)
        // Marie payé 100, doit 117 (90% de 130) → net −17 (débitrice)
        #expect(result.partner1Net == 17)
        #expect(result.partner2Net == -17)
        #expect(result.status == .partner2OwesPartner1(17))
    }

    /// Invariant global : la somme des soldes nets doit toujours être nulle
    /// (ou quasi-nulle selon l'arrondi), quelle que soit la combinaison de dépenses.
    @Test("Invariant — somme des soldes nets = 0")
    func netSumIsZero() {
        let expenses = [
            Expense(title: "A", amount: 66, paidBy: .partner1,
                    splitRatio: .custom(partner1Share: 30, partner2Share: 70)),
            Expense(title: "B", amount: 44, paidBy: .partner2,
                    splitRatio: .custom(partner1Share: 30, partner2Share: 70)),
            Expense(title: "C", amount: 123, paidBy: .partner1,
                    splitRatio: .custom(partner1Share: 55, partner2Share: 45)),
        ]

        let result = BalanceCalculator.calculate(expenses: expenses)

        let sumNets = result.partner1Net + result.partner2Net
        #expect(abs(sumNets) <= Decimal(string: "0.01")!)

        // Vérifie aussi que la somme des parts dues = total
        #expect(result.partner1Due + result.partner2Due == result.totalSpent)
    }
}
