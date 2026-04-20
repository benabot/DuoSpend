import StoreKit
import WidgetKit
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
    private let sharedDefaults = UserDefaults(suiteName: "group.fr.beabot.DuoSpend")
    private var transactionListener: Task<Void, Never>?

    private init() {
        // Lecture du cache partagé — toujours réconcilié par StoreKit ensuite.
        isUnlocked = sharedDefaults?.bool(forKey: "isProUnlocked") ?? false
        transactionListener = listenForTransactions()
        Task { await loadProduct() }
        Task { await checkEntitlement() }
    }

    // MARK: - État Pro

    /// Persiste l'état et rafraîchit les widgets
    private func setUnlocked(_ value: Bool) {
        isUnlocked = value
        sharedDefaults?.set(value, forKey: "isProUnlocked")
        WidgetCenter.shared.reloadAllTimelines()
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
                    setUnlocked(true)
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
            // Ne pas afficher d'erreur si l'utilisateur a simplement annulé
            if let skError = error as? StoreKitError, case .userCancelled = skError {
                logger.info("User cancelled purchase (StoreKitError)")
            } else if (error as? SKError)?.code == .paymentCancelled {
                logger.info("User cancelled purchase (SKError.paymentCancelled)")
            } else {
                purchaseError = error.localizedDescription
                logger.error("Purchase failed: \(error)")
            }
        }
    }

    // MARK: - Vérification des droits

    func checkEntitlement() async {
        var hasActiveEntitlement = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == productID {
                hasActiveEntitlement = true
                break
            }
        }

        #if DEBUG
        if !hasActiveEntitlement, Self.isScreenshotRouteActive {
            logger.info("Skipping entitlement reset while screenshot route is active")
            return
        }
        #endif

        setUnlocked(hasActiveEntitlement)
        if hasActiveEntitlement {
            logger.info("Entitlement found: \(self.productID)")
        } else {
            logger.info("No entitlement found: \(self.productID)")
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
            if let skError = error as? StoreKitError, case .userCancelled = skError {
                logger.info("User cancelled restore (caught as error)")
            } else {
                purchaseError = error.localizedDescription
                logger.error("Restore failed: \(error)")
            }
        }
    }

    // MARK: - Listener transactions

    private func listenForTransactions() -> Task<Void, Never> {
        Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    if transaction.productID == productID {
                        setUnlocked(true)
                        logger.info("Transaction update: unlocked")
                    }
                }
            }
        }
    }

    // MARK: - Debug

    #if DEBUG
    private static var isScreenshotRouteActive: Bool {
        let processInfo = ProcessInfo.processInfo
        if processInfo.environment["SCREENSHOT_ROUTE"] != nil {
            return true
        }
        return processInfo.arguments.contains("--screenshot-route")
    }

    func debugUnlock() { setUnlocked(true) }
    func debugLock() { setUnlocked(false) }
    #endif
}
