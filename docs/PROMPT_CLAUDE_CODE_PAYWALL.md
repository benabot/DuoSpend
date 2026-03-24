# Prompt Claude Code — StoreKit 2 Paywall v1.0

## Contexte

DuoSpend est une app iOS SwiftUI (Swift 6, iOS 17+, SwiftData, zéro dépendance tierce).
Le repo est dans `/Users/benoitabot/Sites/DuoSpend`.

**Lis d'abord** : `CLAUDE.md` puis `docs/DECISIONS.md` (entrée du 2026-03-25 sur le pricing).

## Objectif

Implémenter le paywall StoreKit 2 :
- **1 projet gratuit** — toutes les features accessibles.
- **Achat unique 6,99 €** — débloque les projets illimités à vie.
- Product ID : `com.duospend.unlimitedprojects` (Non-Consumable).
- Le paywall se déclenche à la création du **2e projet**.

## Fichiers à créer

### 1. `DuoSpend/Services/StoreManager.swift`

Singleton `@Observable` qui gère l'état d'achat.

```swift
import StoreKit
import os

@Observable
final class StoreManager {
    static let shared = StoreManager()
    
    private(set) var isUnlocked = false
    private(set) var product: Product?
    private(set) var purchaseError: String?
    private(set) var isLoading = false
    
    private let productID = "com.duospend.unlimitedprojects"
    private let logger = Logger(subsystem: "fr.beabot.DuoSpend", category: "StoreManager")
    private var transactionListener: Task<Void, Never>?
    
    private init() {
        transactionListener = listenForTransactions()
        Task { await loadProduct() }
        Task { await checkEntitlement() }
    }
}
```

**Méthodes à implémenter :**

- `loadProduct()` — charge le `Product` depuis StoreKit via `Product.products(for:)`. Log les erreurs avec `logger.error`.
- `purchase()` — appelle `product.purchase()`. Gère `.success(.verified)`, `.success(.unverified)`, `.pending`, `.userCancelled`. Appelle `await transaction.finish()` sur succès. Met à jour `isUnlocked`. Gère les erreurs dans `purchaseError`.
- `checkEntitlement()` — boucle sur `Transaction.currentEntitlements`. Si le `productID` est trouvé et vérifié → `isUnlocked = true`.
- `restorePurchases()` — appelle `AppStore.sync()` puis `checkEntitlement()`.
- `listenForTransactions()` — retourne un `Task` qui écoute `Transaction.updates` en boucle infinie. Vérifie et finish chaque transaction.

**Règles strictes :**
- Pas de `ObservableObject` — utiliser `@Observable`.
- Pas de `print()` — utiliser `os.Logger`.
- `@MainActor` sur la classe entière pour la thread safety.

### 2. `DuoSpend/Views/PaywallView.swift`

Sheet modale avec design soigné, pas agressif. Respecter le design system existant (`Color.accentPrimary`, `.rounded`, etc.).

**Structure du layout :**
- En haut : `DuoLogoView(size: 60)` (le composant logo existant)
- Titre : "Passez à DuoSpend Pro" en `.title2.bold()` `.rounded`
- Sous-titre : "Créez autant de projets que vous voulez" en `.body` `.secondary`
- 3 bullet points avec `checkmark.circle.fill` en `Color.successGreen` :
  - "Projets illimités"
  - "Achat unique, pas d'abonnement"
  - "Soutenez un développeur indépendant"
- Bouton principal : "Débloquer pour \(product.displayPrice)" en `.borderedProminent` `.controlSize(.large)` `.tint(Color.accentPrimary)`
- Lien "Restaurer mes achats" en `.plain` `.caption`
- Texte légal en `.caption2` `.tertiary` : "Paiement unique via votre compte Apple. Aucun abonnement."
- `ProgressView` si `storeManager.isLoading`
- Afficher `purchaseError` en rouge si erreur
- Fermer la sheet automatiquement quand `isUnlocked` passe à `true` (utiliser `.onChange(of:)`)

**Localisation :** Tous les textes doivent être des littéraux dans `Text()` pour le String Catalog (pas de variables `String` — cf. décision du 2026-03-24 sur LocalizedStringKey).

### 3. Modifier `DuoSpend/Views/ProjectListView.swift`

Ajouter la logique de paywall dans les points de création de projet.

**Ajouter ces states :**
```swift
@State private var showingPaywall = false
```

**Accéder au StoreManager :**
```swift
private let storeManager = StoreManager.shared
```

**Logique de gate :**
Quand l'utilisateur tape un bouton de création de projet (il y en a 3 dans le code : empty state "C'est parti !", bouton "Nouveau projet" dans le Menu, et bouton "Nouveau projet" en bas de liste) :
- Si `projects.count == 0` → ouvrir `CreateProjectView` (premier projet gratuit)
- Si `projects.count >= 1 && !storeManager.isUnlocked` → ouvrir `PaywallView` en sheet
- Si `storeManager.isUnlocked` → ouvrir `CreateProjectView`

**Extraire la logique dans une méthode :**
```swift
private func handleNewProject() {
    if projects.isEmpty || storeManager.isUnlocked {
        showingCreateProject = true
    } else {
        showingPaywall = true
    }
}
```

Appeler `handleNewProject()` dans les 3 boutons au lieu de `showingCreateProject = true`.

**Ajouter la sheet paywall :**
```swift
.sheet(isPresented: $showingPaywall) {
    PaywallView()
}
```

### 4. Configuration StoreKit pour les tests Xcode

Créer un fichier `SETUP_STOREKIT.md` dans `docs/` qui documente la procédure suivante (le fichier `.storekit` doit être créé manuellement dans Xcode) :

```markdown
## Créer la configuration StoreKit de test

1. Dans Xcode : File > New > File > StoreKit Configuration File
2. Nom : `DuoSpendStore.storekit`
3. Emplacement : `DuoSpend/Resources/`
4. NE PAS cocher "Sync this file with an app in App Store Connect"
5. Ajouter un produit :
   - Type : Non-Consumable
   - Reference Name : DuoSpend Pro
   - Product ID : com.duospend.unlimitedprojects
   - Price : 6.99
   - Display Name (fr) : DuoSpend Pro
   - Description (fr) : Débloquer les projets illimités
   - Display Name (en) : DuoSpend Pro
   - Description (en) : Unlock unlimited projects
6. Dans le scheme Xcode (Edit Scheme > Run > Options) :
   - StoreKit Configuration : sélectionner `DuoSpendStore.storekit`
```

### 5. Debug/Preview : tester les différents états du paywall

Créer `DuoSpend/Views/Components/PaywallDebugView.swift` — un écran de debug accessible **uniquement en mode DEBUG** pour tester visuellement les états.

**Ce qu'il doit permettre :**

```swift
#if DEBUG
struct PaywallDebugView: View {
    @State private var showingPaywall = false
    
    var body: some View {
        List {
            Section("État StoreManager") {
                LabeledContent("isUnlocked", value: "\(StoreManager.shared.isUnlocked)")
                LabeledContent("Product chargé", value: StoreManager.shared.product != nil ? "✅" : "❌")
                if let error = StoreManager.shared.purchaseError {
                    LabeledContent("Erreur", value: error)
                }
            }
            
            Section("Actions de test") {
                Button("Ouvrir PaywallView") { showingPaywall = true }
                Button("Simuler achat réussi") { StoreManager.shared.debugUnlock() }
                Button("Simuler état gratuit") { StoreManager.shared.debugLock() }
                Button("Restaurer achats") { Task { await StoreManager.shared.restorePurchases() } }
            }
        }
        .navigationTitle("Debug Paywall")
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }
}
#endif
```

**Ajouter dans `StoreManager.swift` :**
```swift
#if DEBUG
func debugUnlock() { isUnlocked = true }
func debugLock() { isUnlocked = false }
#endif
```

**Rendre le debug accessible dans l'app :**
Dans `ProjectListView`, ajouter un bouton caché en mode DEBUG dans la toolbar :
```swift
#if DEBUG
ToolbarItem(placement: .navigationBarLeading) {
    NavigationLink(destination: PaywallDebugView()) {
        Image(systemName: "ladybug")
            .foregroundStyle(.secondary)
    }
}
#endif
```

## Enregistrement Xcode

Tous les nouveaux fichiers `.swift` doivent être enregistrés dans le projet Xcode.
Utiliser le pattern xcodeproj gem :
```ruby
require 'xcodeproj'
project = Xcodeproj::Project.open('DuoSpend.xcodeproj')
target = project.targets.first
# Pour chaque nouveau fichier :
group = project['DuoSpend']['Services'] # ou Views, Components...
file_ref = group.new_file('StoreManager.swift')
target.source_build_phase.add_file_reference(file_ref)
project.save
```

## Checklist de validation

Avant de committer, vérifier :

1. `xcodebuild build -scheme DuoSpend -destination 'platform=iOS Simulator,name=iPhone 16' 2>&1 | grep -E "(error:|BUILD)" | grep -v "appintents"` → BUILD SUCCEEDED
2. L'app se lance sans crash dans le simulateur
3. Avec 0 projets : le bouton "C'est parti !" ouvre CreateProjectView (pas le paywall)
4. Avec 1 projet : le bouton "+" pour nouveau projet ouvre le PaywallView
5. PaywallView affiche le prix dynamique (ou "Chargement..." si le produit n'est pas encore loadé)
6. Le bouton "Restaurer mes achats" ne crash pas
7. En mode DEBUG : le PaywallDebugView est accessible via l'icône ladybug
8. "Simuler achat réussi" dans le debug → les boutons de création passent par CreateProjectView
9. "Simuler état gratuit" → les boutons reviennent au paywall
10. Aucun `print()` dans le code — uniquement `os.Logger`
11. Aucun `ObservableObject` — uniquement `@Observable`

## Commits

- `feat: ajout StoreManager StoreKit 2`
- `feat: ajout PaywallView`
- `feat: gate création projet derrière paywall`
- `feat: ajout PaywallDebugView (DEBUG only)`

Mettre à jour `docs/TODO.md` : cocher la tâche StoreKit 2.
