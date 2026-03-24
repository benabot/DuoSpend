# DuoSpend — TODO

## Phase 1 : Setup projet Xcode (Sprint 1) ✅

- [x] Créer le projet Xcode dans `/Users/benoitabot/Sites/DuoSpend/`
- [x] Organiser les dossiers : App/, Models/, Views/, ViewModels/, Services/, Extensions/, Components/
- [x] Créer `Project.swift` (@Model SwiftData)
- [x] Créer `Expense.swift` (@Model SwiftData)
- [x] Créer `PartnerRole.swift` (enum)
- [x] Créer `SplitRatio.swift` (enum Codable)
- [x] Configurer le `ModelContainer` dans `DuoSpendApp.swift`
- [x] Créer `SampleData.swift` dans Preview Content (données de test)
- [x] Vérifier : le projet compile, les previews fonctionnent

## Phase 2 : Écrans principaux (Sprint 2) ✅

- [x] `ProjectListView` : état vide + liste de cards
- [x] `ProjectCard` : composant card dans la liste
- [x] `CreateProjectView` : sheet formulaire nouveau projet
- [x] `ProjectDetailView` : header + balance + liste dépenses
- [x] `ExpenseRow` : composant ligne dépense
- [x] `BalanceBanner` : composant encart balance
- [x] `AddExpenseView` : sheet formulaire ajout dépense
- [x] NavigationStack : navigation entre les écrans
- [x] Vérifier : parcours complet fonctionne (créer projet → ajouter dépense → voir balance)

## Phase 3 : Logique métier (Sprint 3) ✅

- [x] `BalanceCalculator.swift` : service de calcul pur
- [x] `BalanceResult` + `BalanceStatus` : types de retour
- [x] Tests unitaires : scénario 50/50
- [x] Tests unitaires : scénario custom split
- [x] Tests unitaires : scénario équilibre
- [x] Tests unitaires : scénario une seule dépense
- [x] Intégrer le calcul dans `ProjectDetailView` / ViewModel
- [x] `Decimal+Currency.swift` : extension formatage montants
- [x] `xcodebuild build` — BUILD SUCCEEDED
- [x] `xcodebuild test` — 5/5 tests passent
- [x] Parcours complet simulateur validé

## Phase 4 : Polish UX (Sprint 4) ✅

- [x] Swipe to delete dépenses
- [x] Alert confirmation suppression projet
- [x] Édition d'une dépense existante (tap → sheet pré-remplie)
- [x] Édition d'un projet existant (nom, partenaires, budget) — EditProjectView
- [x] Couleurs par partenaire (bleu / rose) cohérentes partout
- [x] Dark mode vérifié sur tous les écrans (couleurs sémantiques partout)
- [x] Haptic feedback sur ajout dépense et création projet
- [x] Animations de transition sheets — `.presentationDetents` + `.presentationCornerRadius(20)`
- [x] Validation formulaires renforcée (montant ≤ 0, noms identiques)
- [x] Tri dépenses par date (plus récentes en haut) + option tri par montant/payeur
- [x] Formatage montants : symbole € correctement placé (locale fr_FR forcée)

## Phase 5 : Persistance & Test device (Sprint 5)

- [ ] Vérifier persistance SwiftData (kill app → données toujours là)
- [ ] Tester sur device physique (pas juste simulateur)
- [ ] Vérifier iCloud sync basique (même compte Apple, 2 devices)
- [ ] Tester les edge cases : montant 0, nom vide, très long texte
- [ ] Tester performance avec 50+ dépenses dans un projet

## Phase 6 : Design & Identité visuelle (Sprint 6) ✅

- [x] **Splash screen animé** : SplashScreenView avec scale+bounce+fade, transition auto vers ProjectListView après 2s
- [x] **Palette de couleurs fun** : 5 color sets dans xcassets (AccentPrimary, Partner1, Partner2, CardBackground, SuccessGreen) + Color+DuoSpend extension
- [x] **ProjectCard redesign** : emoji dans cercle teinté, mini ProgressView budget, label avec icône pour la balance
- [x] **BalanceBanner redesign** : LinearGradient coloré, texte blanc, flèche arrow.right entre noms, typo .rounded
- [x] **ExpenseRow amélioré** : avatar cercle 36pt avec initiale du payeur en blanc, montant en .rounded .semibold
- [x] **Typographie vivante** : .rounded sur montants, compteurs, titres de section
- [x] **Empty states illustrés** : heart.circle.fill 60pt avec .symbolEffect(.pulse), texte engageant, bouton .large
- [x] **Micro-animations** : .spring() sur liste, .contentTransition(.numericText()) sur BalanceBanner, .presentationCornerRadius(20) sur sheets
- [x] **Section résumé dans ProjectDetail** : DisclosureGroup repliable avec totaux, compteurs, barre contribution colorée
- [x] **Icône d'app** : AppIconExporter.swift dans Preview Content (2 cœurs bleu/rose + € sur fond violet)
- [x] Couleurs partenaire cohérentes partout (Color.partner1 / Color.partner2 au lieu de .blue / .pink)

## Phase 7 : Préparation App Store (en cours)

- [x] Localisation FR + EN (String Catalog .xcstrings) ✅ 2026-03-24
- [x] StoreKit 2 — paywall 1 projet gratuit + achat unique 6,99 € ✅ 2026-03-25
- [ ] Privacy Policy sur beabot.fr/duospend/privacy
- [ ] Support URL sur beabot.fr/duospend/support
- [ ] Screenshots simulateur (6.7" + 5.5") FR et EN
- [ ] Métadonnées App Store FR + EN
- [ ] Vérifier PrivacyInfo.xcprivacy complet
- [ ] Version 1.0.0 / Build 1
- [ ] Créer compte Apple Developer
- [ ] Archive Release → Validate → Upload
- [ ] TestFlight beta
- [ ] Soumission App Store

---

## Backlog post-MVP (v2)

- [ ] Sync locale MultipeerConnectivity (code retiré de v1, récupérable via git commit 9a501b7)
- [ ] iCloud sync même compte Apple (v1.1)
- [ ] CloudKit Sharing 2 comptes Apple (v2.0)
- [ ] Templates projets (mariage, voyage, travaux, bébé, déménagement)
- [ ] Catégories de dépenses avec icônes SF Symbols
- [ ] Graphiques répartition (Charts framework)
- [ ] Onboarding première ouverture
- [ ] Recherche dans les dépenses
- [ ] App Clip ou partage projet


## Phase 8 : Sync couple — CloudKit Sharing (v2.0)

### v1.1 — iCloud sync même compte Apple
- [ ] Activer `cloudKitDatabase: .automatic` dans `ModelConfiguration` (remplacer `.none`)
- [ ] Configurer les entitlements CloudKit dans Xcode (iCloud capability + CloudKit container)
- [ ] Créer le container CloudKit `iCloud.fr.beabot.DuoSpend` dans le portail Apple Developer
- [ ] Tester avec 2 devices sur le même Apple ID → les projets se synchronisent
- [ ] Gérer les conflits de merge (last-write-wins par défaut SwiftData)
- [ ] Tester la sync offline → online (mode avion, ajout dépense, reconnexion)

### v2.0 — CloudKit Sharing (2 comptes Apple séparés)
- [ ] Configurer `NSPersistentCloudKitContainer` pour les zones partagées
- [ ] Créer un `SharingService` : génération de `CKShare` par projet
- [ ] UI d'invitation : bouton "Inviter mon partenaire" dans `ProjectDetailView`
- [ ] Intégrer `UICloudSharingController` ou générer un lien custom (`CKShare.URL`)
- [ ] Gérer l'acceptation du partage côté destinataire (Universal Link / `userDidAcceptCloudKitShareWith`)
- [ ] Distinguer projets perso / projets partagés dans `ProjectListView`
- [ ] Afficher un indicateur de sync (icône cloud) sur les projets partagés
- [ ] Gérer la révocation du partage (supprimer l'accès d'un partenaire)
- [ ] Tester avec 2 comptes Apple différents sur 2 devices
- [ ] Tester les edge cases : suppression d'une dépense par l'un pendant que l'autre est offline
- [ ] Tester les permissions : seul le créateur peut supprimer le projet
