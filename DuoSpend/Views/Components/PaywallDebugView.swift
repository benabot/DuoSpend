#if DEBUG
import SwiftUI

/// Écran de debug pour tester les états du paywall — DEBUG uniquement
struct PaywallDebugView: View {
    @State private var showingPaywall = false
    @State private var storeManager = StoreManager.shared

    var body: some View {
        List {
            Section("État StoreManager") {
                LabeledContent("isUnlocked", value: "\(storeManager.isUnlocked)")
                LabeledContent("Product chargé", value: storeManager.product != nil ? "✅" : "❌")
                if let price = storeManager.product?.displayPrice {
                    LabeledContent("Prix", value: price)
                }
                if let error = storeManager.purchaseError {
                    LabeledContent("Erreur", value: error)
                        .foregroundStyle(.red)
                }
            }

            Section("Actions de test") {
                Button("Ouvrir PaywallView") { showingPaywall = true }
                Button("Simuler achat réussi") { storeManager.debugUnlock() }
                Button("Simuler état gratuit") { storeManager.debugLock() }
                Button("Restaurer achats") {
                    Task { await storeManager.restorePurchases() }
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
