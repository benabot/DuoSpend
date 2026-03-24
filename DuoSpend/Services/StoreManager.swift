import StoreKit
import os

/// Gestion des achats StoreKit 2 — singleton @Observable thread-safe sur le MainActor
@Observable
@MainActor
final class StoreManager {
    static let shared = StoreManager()

    private(set) var isUnlocked = false
    private(set) var product: Product?
    private(set) var purchaseError: String?
    private(set) var isLoading = false

    private let productID = "fr.beabot.DuoSpend.unlimitedprojects"
    private let logger = Logger(subsystem: "fr.beabot.DuoSpend", category: "StoreManager")
    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = listenForTransactions()
        Task { await loadProduct() }
        Task { await checkEntitlement() }
    }

    // MARK: - Chargement produit

    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
            logger.info("Product loaded: \(self.product?.displayName ?? "none")")
        } catch {
            logger.error("Failed to load product: \(error)")
        }
    }

    // MARK: - Achat

    func purchase() async {
        guard let product else {
            purchaseError = "Produit non disponible"
            return
        }
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    isUnlocked = true
                    logger.info("Purchase verified and completed")
                case .unverified(_, let error):
                    purchaseError = "Vérification échouée"
                    logger.error("Purchase unverified: \(error)")
                }
            case .pending:
                logger.info("Purchase pending approval")
            case .userCancelled:
                logger.info("User cancelled purchase")
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
            logger.error("Purchase failed: \(error)")
        }
    }

    // MARK: - Vérification des droits

    func checkEntitlement() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productID {
                isUnlocked = true
                logger.info("Entitlement found: \(self.productID)")
                return
            }
        }
    }

    // MARK: - Restauration

    func restorePurchases() async {
        isLoading = true
        purchaseError = nil
        defer { isLoading = false }
        do {
            try await AppStore.sync()
            await checkEntitlement()
            logger.info("Restore completed")
        } catch {
            purchaseError = error.localizedDescription
            logger.error("Restore failed: \(error)")
        }
    }

    // MARK: - Listener transactions

    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    if transaction.productID == productID {
                        isUnlocked = true
                        logger.info("Transaction update: unlocked")
                    }
                }
            }
        }
    }

    // MARK: - Debug

    #if DEBUG
    func debugUnlock() { isUnlocked = true }
    func debugLock() { isUnlocked = false }
    #endif
}
