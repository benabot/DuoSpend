#if DEBUG
import SwiftUI

@MainActor
protocol PaywallDebugStore: AnyObject {
    var isUnlocked: Bool { get }
    var hasLoadedProduct: Bool { get }
    var loadedProductPrice: String? { get }
    var purchaseErrorMessage: String? { get }

    func simulateSuccessfulPurchase()
    func simulateFreeState()
    func restorePurchases() async
}

extension StoreManager: PaywallDebugStore {
    var hasLoadedProduct: Bool { product != nil }
    var loadedProductPrice: String? { product?.displayPrice }
    var purchaseErrorMessage: String? { purchaseError }

    func simulateSuccessfulPurchase() { debugUnlock() }
    func simulateFreeState() { debugLock() }
}

@MainActor
struct PaywallDebugSnapshot: Equatable {
    let isUnlockedText: String
    let productLoadedText: String
    let displayedPrice: String?
    let displayedError: String?

    init(store: any PaywallDebugStore) {
        isUnlockedText = "\(store.isUnlocked)"
        productLoadedText = store.hasLoadedProduct ? "✅" : "❌"
        displayedPrice = store.loadedProductPrice
        displayedError = store.purchaseErrorMessage
    }
}

@MainActor
final class PaywallDebugActions {
    private let store: any PaywallDebugStore

    init(store: any PaywallDebugStore) {
        self.store = store
    }

    func simulateSuccessfulPurchase() {
        store.simulateSuccessfulPurchase()
    }

    func simulateFreeState() {
        store.simulateFreeState()
    }

    func restorePurchases() async {
        await store.restorePurchases()
    }
}

/// Écran de debug pour tester les états du paywall — DEBUG uniquement
struct PaywallDebugView: View {
    @State private var showingPaywall = false
    @State private var storeManager = StoreManager.shared

    private var snapshot: PaywallDebugSnapshot {
        PaywallDebugSnapshot(store: storeManager)
    }

    private var actions: PaywallDebugActions {
        PaywallDebugActions(store: storeManager)
    }

    var body: some View {
        List {
            Section("État StoreManager") {
                LabeledContent("isUnlocked", value: snapshot.isUnlockedText)
                LabeledContent("Product chargé", value: snapshot.productLoadedText)
                if let price = snapshot.displayedPrice {
                    LabeledContent("Prix", value: price)
                }
                if let error = snapshot.displayedError {
                    LabeledContent("Erreur", value: error)
                        .foregroundStyle(.red)
                }
            }

            Section("Actions de test") {
                Button("Ouvrir PaywallView") { showingPaywall = true }
                Button("Simuler achat réussi") { actions.simulateSuccessfulPurchase() }
                Button("Simuler état gratuit") { actions.simulateFreeState() }
                Button("Restaurer achats") {
                    Task { await actions.restorePurchases() }
                }
            }
        }
        .navigationTitle("Debug Paywall")
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
    }
}

#Preview {
    NavigationStack {
        PaywallDebugView()
    }
}
#endif
