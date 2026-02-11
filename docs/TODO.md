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

---

## Backlog post-MVP

- [ ] Templates projets (mariage, voyage, travaux, bébé, déménagement)
- [ ] Export PDF récapitulatif (UIGraphicsPDFRenderer)
- [ ] Catégories de dépenses avec icônes SF Symbols
- [ ] Widgets iOS (WidgetKit) — balance du projet principal
- [ ] Graphiques répartition (Charts framework)
- [ ] Paywall StoreKit 2 (1 projet gratuit, illimité = 6,99€)
- [ ] Onboarding première ouverture
- [ ] Recherche dans les dépenses
- [ ] App Clip ou partage projet
