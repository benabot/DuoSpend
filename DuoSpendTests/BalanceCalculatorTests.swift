import Testing
@testable import DuoSpend

@Suite("BalanceCalculator")
struct BalanceCalculatorTests {

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
}
