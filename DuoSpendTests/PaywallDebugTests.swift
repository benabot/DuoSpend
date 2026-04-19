import Foundation
import Testing
@testable import DuoSpend

@MainActor
private final class PaywallDebugStoreStub: PaywallDebugStore {
    var isUnlocked: Bool
    var hasLoadedProduct: Bool
    var loadedProductPrice: String?
    var purchaseErrorMessage: String?

    private(set) var simulateSuccessfulPurchaseCallCount = 0
    private(set) var simulateFreeStateCallCount = 0
    private(set) var restorePurchasesCallCount = 0

    init(
        isUnlocked: Bool = false,
        hasLoadedProduct: Bool = false,
        loadedProductPrice: String? = nil,
        purchaseErrorMessage: String? = nil
    ) {
        self.isUnlocked = isUnlocked
        self.hasLoadedProduct = hasLoadedProduct
        self.loadedProductPrice = loadedProductPrice
        self.purchaseErrorMessage = purchaseErrorMessage
    }

    func simulateSuccessfulPurchase() {
        simulateSuccessfulPurchaseCallCount += 1
        isUnlocked = true
    }

    func simulateFreeState() {
        simulateFreeStateCallCount += 1
        isUnlocked = false
    }

    func restorePurchases() async {
        restorePurchasesCallCount += 1
    }
}

@Suite("Paywall Debug")
@MainActor
struct PaywallDebugTests {

    @Test("État gratuit")
    func freeState() {
        let store = PaywallDebugStoreStub()

        let snapshot = PaywallDebugSnapshot(store: store)

        #expect(snapshot.isUnlockedText == "false")
        #expect(snapshot.productLoadedText == "❌")
        #expect(snapshot.displayedPrice == nil)
    }

    @Test("État déverrouillé / Pro")
    func unlockedState() {
        let store = PaywallDebugStoreStub(isUnlocked: true)

        let snapshot = PaywallDebugSnapshot(store: store)

        #expect(snapshot.isUnlockedText == "true")
    }

    @Test("Produit chargé")
    func loadedProductState() {
        let store = PaywallDebugStoreStub(
            hasLoadedProduct: true,
            loadedProductPrice: "6,99 €"
        )

        let snapshot = PaywallDebugSnapshot(store: store)

        #expect(snapshot.productLoadedText == "✅")
        #expect(snapshot.displayedPrice == "6,99 €")
    }

    @Test("Produit non chargé")
    func unloadedProductState() {
        let store = PaywallDebugStoreStub(hasLoadedProduct: false)

        let snapshot = PaywallDebugSnapshot(store: store)

        #expect(snapshot.productLoadedText == "❌")
        #expect(snapshot.displayedPrice == nil)
    }

    @Test("Prix affiché")
    func displayedPrice() {
        let store = PaywallDebugStoreStub(
            hasLoadedProduct: true,
            loadedProductPrice: "6,99 €"
        )

        let snapshot = PaywallDebugSnapshot(store: store)

        #expect(snapshot.displayedPrice == "6,99 €")
    }

    @Test("Action Simuler achat réussi")
    func simulateSuccessfulPurchaseAction() {
        let store = PaywallDebugStoreStub()
        let actions = PaywallDebugActions(store: store)

        actions.simulateSuccessfulPurchase()

        #expect(store.simulateSuccessfulPurchaseCallCount == 1)
        #expect(store.isUnlocked)
    }

    @Test("Action Simuler état gratuit")
    func simulateFreeStateAction() {
        let store = PaywallDebugStoreStub(isUnlocked: true)
        let actions = PaywallDebugActions(store: store)

        actions.simulateFreeState()

        #expect(store.simulateFreeStateCallCount == 1)
        #expect(!store.isUnlocked)
    }

    @Test("Action Restaurer achats")
    func restorePurchasesAction() async {
        let store = PaywallDebugStoreStub()
        let actions = PaywallDebugActions(store: store)

        await actions.restorePurchases()

        #expect(store.restorePurchasesCallCount == 1)
    }
}
