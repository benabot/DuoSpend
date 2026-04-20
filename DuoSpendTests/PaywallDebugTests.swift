import Foundation
import Testing
@testable import DuoSpend

@MainActor
private struct StringCatalog: Decodable {
    let strings: [String: StringCatalogEntry]

    static func load(relativePath: String, filePath: StaticString = #filePath) throws -> StringCatalog {
        let testsDirectoryURL = URL(fileURLWithPath: "\(filePath)")
            .deletingLastPathComponent()
        let repositoryRootURL = testsDirectoryURL.deletingLastPathComponent()
        let catalogURL = repositoryRootURL
            .appendingPathComponent(relativePath)
        let data = try Data(contentsOf: catalogURL)
        return try JSONDecoder().decode(StringCatalog.self, from: data)
    }

    static func loadPaywallCatalog(filePath: StaticString = #filePath) throws -> StringCatalog {
        try load(relativePath: "DuoSpend/Resources/Localizable.xcstrings", filePath: filePath)
    }

    static func loadWidgetCatalog(filePath: StaticString = #filePath) throws -> StringCatalog {
        try load(relativePath: "DuoSpendWidget/Localizable.xcstrings", filePath: filePath)
    }

    func englishTranslation(for key: String) -> String? {
        strings[key]?.localizations?["en"]?.stringUnit?.value
    }
}

private struct StringCatalogEntry: Decodable {
    let localizations: [String: StringCatalogLocalization]?
}

private struct StringCatalogLocalization: Decodable {
    let stringUnit: StringCatalogStringUnit?
}

private struct StringCatalogStringUnit: Decodable {
    let value: String?
}

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
    @Test("Localisation EN du paywall")
    func englishPaywallTranslations() throws {
        let catalog = try StringCatalog.loadPaywallCatalog()
        let expectedTranslations = [
            "Passez à DuoSpend Pro": "Upgrade to DuoSpend Pro",
            "Créez autant de projets que vous voulez": "Create as many projects as you want",
            "Projets illimités": "Unlimited projects",
            "Widgets pour l'écran d'accueil": "Home screen widgets",
            "Achat unique, pas d'abonnement": "One-time purchase, no subscription",
            "Soutenez un développeur indépendant": "Support an independent developer",
            "Débloquer pour %@": "Unlock for %@",
            "Chargement…": "Loading…",
            "Restaurer mes achats": "Restore Purchases",
            "Paiement unique via votre compte Apple. Aucun abonnement.": "One-time payment via your Apple account. No subscription.",
            "Fermer": "Close",
        ]

        for (key, expectedTranslation) in expectedTranslations {
            #expect(catalog.englishTranslation(for: key) == expectedTranslation)
        }
    }

    @Test("Localisation EN du debug paywall")
    func englishPaywallDebugTranslations() throws {
        let catalog = try StringCatalog.loadPaywallCatalog()
        let expectedTranslations = [
            "État StoreManager": "StoreManager State",
            "Product chargé": "Product loaded",
            "Prix": "Price",
            "Erreur": "Error",
            "Actions de test": "Test Actions",
            "Ouvrir PaywallView": "Open PaywallView",
            "Simuler achat réussi": "Simulate successful purchase",
            "Simuler état gratuit": "Simulate free state",
            "Restaurer achats": "Restore purchases",
            "Debug Paywall": "Debug Paywall",
        ]

        for (key, expectedTranslation) in expectedTranslations {
            #expect(catalog.englishTranslation(for: key) == expectedTranslation)
        }
    }

    @Test("Localisation EN des widgets")
    func englishWidgetTranslations() throws {
        let catalog = try StringCatalog.loadWidgetCatalog()
        let expectedTranslations = [
            "Affiche la balance du projet en cours.": "Shows the balance of the current project.",
            "Balance de votre projet en cours.": "Balance of your current project.",
            "Dernières dépenses": "Recent expenses",
            "Déverrouillez pour accéder aux widgets": "Unlock to access widgets",
            "DuoSpend Pro": "DuoSpend Pro",
            "Équilibre": "Balanced",
            "%@ doit": "%@ owes",
            "à %@": "to %@",
        ]

        for (key, expectedTranslation) in expectedTranslations {
            #expect(catalog.englishTranslation(for: key) == expectedTranslation)
        }
    }

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
