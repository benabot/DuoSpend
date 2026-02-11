# Prompt Claude Code — In-App Purchase : débloquer projets illimités

> Copie-colle ce prompt dans Claude Code depuis `~/Sites/DuoSpend`

---

## Contexte

Lis `CLAUDE.md`. L'app fonctionne, la navigation est OK. On ajoute maintenant la **monétisation** : le premier projet est gratuit, les suivants nécessitent un achat unique (In-App Purchase).

## Modèle économique

- **1 projet gratuit** : l'utilisateur peut créer et utiliser 1 projet sans payer
- **Projets illimités** : achat unique (non-consommable) à 3,99 € via StoreKit 2
- Product ID : `com.duospend.unlimitedprojects`
- Une fois acheté, c'est débloqué **à vie** (pas d'abonnement)

---

## Implémentation

### 1. Créer `Services/StoreManager.swift`

Un `@Observable` class qui gère StoreKit 2 :

```swift
import StoreKit
import SwiftUI

@Observable
class StoreManager {
    static let shared = StoreManager()
    
    private let productID = "com.duospend.unlimitedprojects"
    
    var isUnlocked: Bool = false
    var product: Product?
    var purchaseError: String?
    
    private init() {
        // Vérifier si déjà acheté au lancement
        Task { await checkPurchaseStatus() }
    }
    
    /// Charger le produit depuis l'App Store
    func loadProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {
            purchaseError = "Impossible de charger le produit."
        }
    }
    
    /// Acheter le produit
    func purchase() async {
        guard let product else { return }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isUnlocked = true
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Achat en attente de validation."
            @unknown default:
                break
            }
        } catch {
            purchaseError = "Erreur lors de l'achat."
        }
    }
    
    /// Restaurer les achats
    func restore() async {
        try? await AppStore.sync()
        await checkPurchaseStatus()
    }
    
    /// Vérifier le statut des achats existants
    private func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == productID {
                isUnlocked = true
                return
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.unverified
        }
    }
    
    enum StoreError: Error {
        case unverified
    }
}
```

### 2. Créer `Views/PaywallView.swift`

Un écran de paywall qui s'affiche en sheet. Design soigné, pas agressif :

- En haut : SF Symbol `heart.circle.fill` en 60pt, couleur `.accentPrimary`
- Titre : "Passez à DuoSpend Pro" en `.title2.bold()` design `.rounded`
- Sous-titre : "Créez autant de projets que vous voulez" en `.body` `.secondary`
- 3 bullet points avec SF Symbols :
  - `checkmark.circle.fill` "Projets illimités"
  - `checkmark.circle.fill` "Achat unique, pas d'abonnement"  
  - `checkmark.circle.fill` "Soutenez un développeur indépendant"
- Bouton principal : "Débloquer pour [prix dynamique]" en `.borderedProminent` `.controlSize(.large)`, couleur `.accentPrimary`
- En dessous : "Restaurer mes achats" en `.plain` `.caption` 
- En bas : texte légal en `.caption2` `.tertiary` : "Paiement unique via votre compte Apple. Aucun abonnement."
- Le prix doit être récupéré dynamiquement depuis `product.displayPrice` (pas hardcodé)
- Afficher un `ProgressView` si le produit est en cours de chargement
- Afficher `purchaseError` s'il y a une erreur
- Quand l'achat réussit : fermer la sheet automatiquement

### 3. Modifier `ProjectListView.swift`

Quand l'utilisateur tape "+" ou "C'est parti !" :
- Si `projects.count == 0` → ouvrir `CreateProjectView` (gratuit)
- Si `projects.count >= 1` ET `!StoreManager.shared.isUnlocked` → ouvrir `PaywallView` en sheet
- Si `StoreManager.shared.isUnlocked` → ouvrir `CreateProjectView`

Ajoute un `@State private var showingPaywall = false` et la logique dans les boutons existants.

Le `StoreManager.shared` doit être accessible : ajoute `.environment(StoreManager.shared)` dans `DuoSpendApp.swift` OU utilise directement `StoreManager.shared` comme singleton.

### 4. Créer le fichier de configuration StoreKit pour les tests

Créer `DuoSpend/Resources/StoreKitConfig.storekit` — un fichier de configuration StoreKit pour tester en sandbox dans Xcode :

```json
{
  "identifier" : "com.duospend.unlimitedprojects",
  "displayName" : "DuoSpend Pro",
  "description" : "Débloquer les projets illimités",
  "price" : "3.99",
  "type" : "NonConsumable",
  "locale" : "fr_FR"
}
```

Note : ce fichier se crée normalement via Xcode (File > New > StoreKit Configuration File). Si tu ne peux pas le créer programmatiquement, crée un fichier `SETUP_STOREKIT.md` qui documente la procédure manuelle pour le développeur.

### 5. Ajouter dans `project.yml` (xcodegen)

S'assurer que les fichiers StoreKit sont inclus dans le projet. Ajouter StoreKit dans les frameworks si nécessaire (normalement pas besoin, c'est natif).

### 6. Mettre à jour `DuoSpendApp.swift`

- Appeler `StoreManager.shared.loadProduct()` dans une `.task {}` au démarrage
- Écouter les transactions en background :
```swift
.task {
    for await result in Transaction.updates {
        if let transaction = try? StoreManager.shared.checkVerified(result) {
            StoreManager.shared.isUnlocked = true
            await transaction.finish()
        }
    }
}
```
Note : il faudra peut-être rendre `checkVerified` internal au lieu de private pour ça. Ou ajouter une méthode `listenForTransactions()` dans StoreManager.

---

## Contraintes

- StoreKit 2 uniquement (pas StoreKit 1 / SKPayment)
- iOS 17+
- Zéro dépendance tierce
- Ne pas casser la navigation existante
- Ne pas modifier la logique de création/calcul/suppression
- `xcodebuild build` doit passer
- Les 5 tests existants doivent passer
- Commit : `git add -A && git commit -m "Feature: paywall StoreKit 2 — projets illimités à 3,99€"`

---

## Important

Le vrai achat ne fonctionnera qu'après :
1. Avoir un compte Apple Developer (99 €/an)
2. Avoir créé le produit IAP dans App Store Connect
3. Avoir configuré le StoreKit Testing dans le scheme Xcode

Pour l'instant, on code toute la mécanique. Les tests en sandbox se font via le StoreKit Configuration File dans Xcode.
