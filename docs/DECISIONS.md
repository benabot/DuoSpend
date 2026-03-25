# DuoSpend — Decisions Log

Format recommandé :

```text
### [DATE] — [TITRE]
**Contexte** : pourquoi la question se posait
**Décision** : ce qui a été choisi
**Alternatives rejetées** : options écartées et pourquoi
**Impact** : conséquence pratique dans le code ou le produit
```

---

### 2025-02-10 — SwiftUI comme couche UI principale

**Contexte** : choix de la technologie d'interface pour le MVP.

**Décision** : utiliser SwiftUI comme couche UI principale de l'app.

**Alternatives rejetées** :
- UIKit majoritaire → plus verbeux, moins cohérent avec Observation et SwiftData
- architecture hybride UIKit/SwiftUI → complexité inutile pour un produit de cette taille

**Impact** : les écrans sont conçus en SwiftUI ; UIKit reste éventuellement limité à des points d'intégration système.

---

### 2025-02-10 — SwiftData comme persistance principale

**Contexte** : choix de la solution de stockage local avec possibilité d'évolution vers iCloud.

**Décision** : SwiftData comme couche de persistance principale.

**Alternatives rejetées** :
- Core Data → plus verbeux, intégration moins directe pour ce scope
- Realm → dépendance tierce
- SQLite / GRDB → trop bas niveau pour le MVP

**Impact** : modèles annotés `@Model`, lectures simples via `@Query`, mutations via `ModelContext`.

---

### 2025-02-10 — Architecture MVVM avec Observation framework

**Contexte** : choix d'architecture pour séparer UI, orchestration et logique métier.

**Décision** : MVVM avec `@Observable`.

**Alternatives rejetées** :
- TCA → trop complexe pour la taille du projet + dépendance tierce
- MV sans ViewModel → insuffisant pour la logique d'écran
- VIPER → disproportionné pour une app indie solo

**Impact** : `@Observable` remplace `ObservableObject` ; les vues gardent une responsabilité d'affichage.

---

### 2025-02-10 — Tous les montants métier en Decimal

**Contexte** : quel type utiliser pour représenter l'argent.

**Décision** : `Decimal` pour tous les montants métier.

**Alternatives rejetées** :
- `Double` → imprécisions d'arrondi inacceptables
- `Int` en centimes → viable mais moins lisible pour l'état actuel du produit

**Impact** : `Double` est exclu des montants fonctionnels et des calculs de balance.

---

### 2025-02-10 — Aucune dépendance tierce

**Contexte** : utiliser ou non des bibliothèques externes.

**Décision** : frameworks Apple uniquement.

**Alternatives rejetées** :
- librairies UI / persistance / analytics externes → maintenance accrue, surface de rupture plus large

**Impact** : pas de dépendance tierce pour l'UI, la persistance, la sync ou la monétisation.

---

### 2025-02-10 — Produit limité à deux partenaires

**Contexte** : faut-il supporter 3+ personnes par projet.

**Décision** : non. DuoSpend est strictement conçu pour deux partenaires.

**Alternatives rejetées** :
- nombre variable de participants → change le produit et rapproche l'app de Splitwise / Tricount

**Impact** : l'UX, les modèles et le calcul de balance restent optimisés pour 2 personnes uniquement.

---

### 2025-02-10 — Euro comme devise de départ

**Contexte** : faut-il supporter plusieurs devises dès la première version.

**Décision** : centrer le MVP sur l'euro.

**Alternatives rejetées** :
- multi-devises immédiat → complexité produit et UX trop élevée pour le lancement

**Impact** : le MVP peut rester simple ; le multi-devises reste une évolution éventuelle.

---

### 2025-02-11 — Budget obligatoire par projet

**Contexte** : le budget était initialement traité comme optionnel.

**Décision** : le budget devient obligatoire par projet.

**Alternatives rejetées** :
- budget optionnel → rend le produit plus proche d'un simple tracker de dépenses

**Impact** : la création de projet doit exiger un budget ; si le code stocke encore `Decimal?`, il faut corriger cet écart.

---

### 2025-02-11 — Monétisation : achat unique plutôt qu'abonnement

**Contexte** : choisir un modèle économique compatible avec une app utilitaire simple.

**Décision** : privilégier un achat unique pour débloquer les projets illimités plutôt qu'un abonnement.

**Alternatives rejetées** :
- abonnement → trop agressif pour ce type d'usage
- publicité → détériore l'UX

**Impact** : la structure freemium peut être conservée, mais le prix exact et les métadonnées commerciales doivent vivre dans `docs/COMMERCIAL.md`, pas ici.

---

### 2026-03-14 — Stratégie de sync couple progressive

**Contexte** : permettre l'usage par deux partenaires avec des comptes Apple distincts sans casser la simplicité du MVP.

**Décision** : progression en étapes.
- v1.0 : usage local / mono-appareil pour valider le produit
- v1.1 : synchronisation iCloud basique si même compte Apple
- v2.0 : partage CloudKit entre deux comptes Apple distincts

**Alternatives rejetées** :
- backend custom → coût et complexité inutiles
- Firebase / Supabase → dépendance tierce et charge RGPD
- export/import manuel → UX médiocre

**Impact** : la sync existe comme trajectoire produit, mais le MVP ne doit pas en dépendre.

---

### 2026-03-18 — Sync locale ponctuelle via MultipeerConnectivity

**Contexte** : offrir un mode de synchronisation à proximité avant un vrai partage CloudKit complet.

**Décision** : autoriser une sync locale ponctuelle via MultipeerConnectivity comme piste v2.

**Alternatives rejetées** :
- attendre uniquement CloudKit Sharing → trop tardif si un besoin terrain apparaît plus tôt
- AirDrop / fichier manuel → UX fragmentée
- serveur temps réel → surdimensionné

**Impact** : cette piste reste complémentaire de CloudKit Sharing et n'appartient pas au MVP 1.0.

---

### 2026-03-25 — Pricing : 1 projet gratuit + achat unique 6,99 €

**Contexte** : fixer le prix et le modèle de monétisation avant implémentation StoreKit 2.

**Décision** : freemium avec 1 projet gratuit. Achat unique (non-consommable) à 6,99 € pour débloquer les projets illimités à vie. Product ID : `fr.beabot.DuoSpend.unlimitedprojects`.

**Évolution prévue** :
- v1.0 : 6,99 € (prix de lancement optionnel à 4,99 € les 2 premières semaines)
- v1.1 (iCloud sync) : maintien à 6,99 €
- v2.0 (CloudKit Sharing entre 2 comptes) : remontée à 9,99 €

**Alternatives rejetées** :
- 3,99 € → trop bas, perception faible, aucune marge promo
- 4,99 € → insuffisant par rapport à la valeur livrée (widgets, PDF, offline, privacy)
- 9,99–19,99 € dès la v1 → prématuré sans sync couple et sans historique d'avis
- 3 projets gratuits → couvre la majorité des usages réels d'un couple, tue la conversion
- Payant sans projet gratuit → trop risqué au lancement sans notoriété
- Abonnement → trop agressif pour une app utilitaire
- Publicité → détériore l'UX

**Impact** : le paywall se déclenche à la création du 2e projet. Toutes les features restent accessibles dans le projet gratuit.

---

### 2026-03-25 — ZStack au lieu de fullScreenCover pour la transition splash → onboarding

**Contexte** : le `fullScreenCover` + `DispatchQueue.main.asyncAfter(0.3)` provoquait un flash visible de `ProjectListView` (empty state) entre la disparition du splash et l'apparition de l'onboarding.

**Décision** : intégrer `OnboardingView` directement dans le ZStack racine de `DuoSpendApp`, au même niveau que `SplashScreenView`, avec `zIndex(2)` (splash à `zIndex(3)`). L'onboarding apparaît dès que `!hasSeenOnboarding && !showingSplash`, dans le même cycle d'animation que la disparition du splash.

**Alternatives rejetées** :
- `fullScreenCover` + délai → le trou entre la fermeture du splash et l'ouverture de la feuille expose `ProjectListView`
- `fullScreenCover` sans délai → la présentation de sheet échoue si la vue n'est pas encore dans la hiérarchie
- `ZStack` avec `opacity(0)` sur `ProjectListView` → couplage fragile, état supplémentaire inutile

**Impact** : la transition est pilotée par un seul `@AppStorage("hasSeenOnboarding")` et un binding dérivé. Le `withAnimation` dans `OnboardingView.dismiss()` anime la disparition via `.transition(.opacity)`.

---

### 2026-03-25 — AppTheme enum + @AppStorage pour le thème d'apparence

**Contexte** : permettre à l'utilisateur de choisir entre mode système, clair et sombre depuis les réglages, avec persistance entre sessions.

**Décision** : enum `AppTheme: Int, CaseIterable` stocké via `@AppStorage("appTheme")` (Int brut), appliqué avec `.preferredColorScheme(AppTheme(rawValue:)?.colorScheme)` sur le ZStack racine dans `DuoSpendApp`. `colorScheme` retourne `nil` pour `.system`, ce que `.preferredColorScheme` interprète comme "déférer au système".

**Alternatives rejetées** :
- `@AppStorage` avec `String` → conversion manuelle, moins robuste
- `UserDefaults` + `NotificationCenter` → verbeux, non idiomatique SwiftUI
- Appliquer `.preferredColorScheme` dans `SettingsView` → scope trop limité, ne couvre pas toute l'app

**Impact** : `AppTheme.swift` dans `Models/`. Le changement de thème est instantané sans redémarrage. `SettingsView` lit et écrit `@AppStorage("appTheme")` directement, sans ViewModel.

---

### 2026-03-24 — LocalizedStringKey obligatoire pour la traduction SwiftUI

**Contexte** : implémentation de la localisation FR + EN sur l'app iOS avec Xcode 15+ String Catalog (xcstrings).

**Décision** : utiliser `LocalizedStringKey` comme type de paramètre dans les composants personnalisés, plutôt que `String`. Cela garantit que SwiftUI effectue la recherche dans le catalogue de localisation.

**Alternatives rejetées** :
- passer `String` et laisser `Text(String)` gérer la traduction → ne fonctionne pas ; `Text(_: String)` n'effectue pas la recherche de localisation
- utiliser des ternaires pour la logique conditionnelle → les ternaires résolvent d'abord leur type (`String`) avant d'être passés à `Text`, contournant le mécanisme de localisation

**Règle pratique** :
1. Les chaînes littérales dans `Text()` deviennent automatiquement `LocalizedStringKey` : `Text("Modifier")` ✓
2. Les chaînes dynamiques doivent utiliser le type `LocalizedStringKey` : `func sectionCard(title: LocalizedStringKey)` ✓
3. Les ternaires contournent la localisation : `Text(condition ? "A" : "B")` → passer à `if/else` blocks ✗
4. Les montants avec interpolation doivent utiliser `%@` et non `%lld` : `"%@%% du budget"` ✓

**Impact** :
- Tous les composants custom avec des paramètres texte doivent accepter `LocalizedStringKey`.
- Les conditions binaires sur du texte doivent utiliser `Group { if ... } else { ... }` au lieu de ternaires.
- La couche d'affichage respecte strictement le contrat : pas de logique métier texte, pas de formatage dynamique qui contournerait la localisation.
- Bénéfice : intégration automatique avec le String Catalog d'Xcode et support multi-langue transparent.
