# ROADMAP_RELEASE.md — DuoSpend vers l'App Store

> Plan d'exécution détaillé, orienté agent (Codex, ChatGPT, Claude Code).
> Chaque tâche est atomique, testable, et commitable indépendamment.
>
> **Convention** : une tâche = un commit. Un sprint = un PR (ou une série de commits sur `main` si travail solo).

---

## Contexte

- **Racine** : `/Users/benoitabot/Sites/DuoSpend`
- **Repo** : `https://github.com/benabot/DuoSpend`
- **Bundle ID** : `fr.beabot.DuoSpend`
- **Team ID** : `66S2QLG2HD`
- **Cible** : v1.0.0 sur l'App Store — iPhone only, iOS 17+
- **État actuel** : Phases 1 à 6 terminées. Paywall et Pro en place. Il reste Phase 7 (polish + soumission).

---

## Lecture obligatoire avant de démarrer une tâche

Tout agent qui prend une tâche doit avoir lu **dans cet ordre** :

1. `AGENTS.md` (racine) — règles d'exécution agent
2. `CLAUDE.md` (racine) — conventions produit et code
3. `docs/TODO.md` — état de la tâche en cours
4. Ce document, section correspondant à la tâche
5. `docs/DECISIONS.md` — ne pas contredire
6. `docs/DESIGN.md` **uniquement** si la tâche touche l'UI

Ne jamais charger `docs/MVP.md` en entier sauf si la tâche demande une décision produit nouvelle.

---

## Structure en sprints

Le plan est découpé en **8 sprints**. Chaque sprint a :

- un **objectif unique** (ce qui doit être vrai à la fin du sprint)
- une **Definition of Done** (vérifiable à l'œil)
- des **tâches atomiques** (≤ 1 commit chacune)
- des **commandes de validation** (copy-paste)

---

# Sprint 1 — Stabilisation fonctionnelle

**Objectif** : zéro bug connu, zéro warning Xcode, tous les tests verts.

**Durée estimée** : 1 à 2 sessions.

**Definition of Done** :

- `xcodebuild build` passe sans warning (hors AppIntents)
- `xcodebuild test` passe à 100 %
- `git status` est clean
- Aucun TODO ouvert marqué `[bug]` dans `docs/TODO.md`

## Tâches

### 1.1 — Audit des warnings Xcode
- Lancer un build Release complet.
- Lister tous les warnings dans `docs/_scratch/warnings.md` (à créer, non commité).
- Pour chaque warning : classer en `fix now` / `fix later` / `ignore apple`.
- Committer uniquement les fixes : `fix: résorption warnings swift6 strict concurrency`.

**Commandes**
```bash
cd /Users/benoitabot/Sites/DuoSpend
xcodebuild -scheme DuoSpend -configuration Release \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build 2>&1 | grep -E 'warning:|error:' | grep -v appintents > /tmp/duospend_warnings.txt
wc -l /tmp/duospend_warnings.txt
```

### 1.2 — Audit `print()` résiduels
- Rechercher `print(` dans le code applicatif (exclure `Tests/` et `Preview Content/`).
- Remplacer par un `os.Logger` typé par module (`Logger(subsystem: "fr.beabot.DuoSpend", category: "...")`).
- Un commit : `refactor: remplacement des print par os.Logger`.

**Commandes**
```bash
grep -rn "print(" DuoSpend --include="*.swift" \
  | grep -v "Preview Content" \
  | grep -v "Tests"
```

### 1.3 — Audit force-unwrap `!`
- Rechercher les force-unwrap hors `Preview Content/`.
- Remplacer par `guard let` ou `if let`.
- Commit : `refactor: suppression force unwrap hors preview`.

**Commandes**
```bash
grep -rnE '\w!' DuoSpend --include="*.swift" \
  | grep -v "Preview Content" \
  | grep -vE '(!=|//|\*)'
```

### 1.4 — Validation SwiftData
Sur le simulateur, exécuter à la main le scénario :
1. Créer un projet « Test » avec partenaires « A » et « B ».
2. Ajouter 3 dépenses payées alternativement.
3. Fermer et rouvrir l'app (Cmd+Shift+H puis relancer).
4. Vérifier que les 3 dépenses sont toujours là et que la balance est identique.
5. Supprimer le projet. Créer un nouveau projet. Vérifier que rien ne traîne.

Si KO → ouvrir une tâche bug dans `docs/TODO.md` et la traiter avant de passer au sprint suivant.

### 1.5 — Tests unitaires : audit couverture
- Lister les tests existants : `xcodebuild test -scheme DuoSpend -destination 'platform=iOS Simulator,name=iPhone 16 Pro' | grep 'Test Case'`
- Vérifier que `BalanceCalculator` a au moins : cas 50/50, cas 70/30, cas payé uniquement par P1, cas payé uniquement par P2, cas montant = 0, cas liste vide.
- Si un de ces cas manque → l'ajouter. Commit : `test: couverture BalanceCalculator cas limites`.

---

# Sprint 2 — Revue visuelle et polish UI

**Objectif** : l'app est belle sur **tous les écrans iPhone supportés**, en FR et EN, en clair et sombre.

**Durée estimée** : 2 à 3 sessions.

**Definition of Done** :

- Screenshots simulateur pris sur iPhone 16 Pro Max et iPhone SE 3e gén (ou équivalent 5,5" legacy)
- Aucun texte tronqué, aucun overflow
- Balance et montants lisibles partout
- Onboarding sans flash de contenu vide
- Mode sombre validé sur tous les écrans

## Tâches

### 2.1 — Fix onboarding : flash de l'écran vide
**Bug connu** : au premier lancement, on voit brièvement `ProjectListView` vide avant que `.fullScreenCover` de l'onboarding s'ouvre.

**Approche recommandée** :
- Déplacer la décision « afficher onboarding » **avant** le premier rendu de `ProjectListView`.
- Utiliser un `@AppStorage("hasSeenOnboarding")` lu dans `DuoSpendApp` (App root), et rendre conditionnellement `OnboardingView` en plein écran **au lieu** de `ProjectListView` tant que l'onboarding n'est pas terminé.
- Éviter `.fullScreenCover` au premier lancement : préférer un `if !hasSeenOnboarding { OnboardingView() } else { ProjectListView() }` directement dans le root.

Commit : `fix: suppression du flash onboarding au premier lancement`.

### 2.2 — Revue de la typographie
Pour chaque écran principal, vérifier :

- Tous les montants affichés utilisent `.system(..., design: .rounded)`.
- Les titres de projet sont en `.rounded` `.bold`.
- Les labels secondaires n'écrasent pas les montants.
- Les `.caption` restent lisibles en mode sombre.

Écrans à passer en revue :
- `ProjectListView`
- `ProjectDetailView`
- `AddExpenseView`
- `CreateProjectView`
- `EditProjectView`
- `SettingsView`
- `PaywallView`
- `OnboardingView`

Si un écart → commit ciblé : `style: typographie rounded sur <Écran>`.

### 2.3 — Revue des espacements
Règle produit : **aérer les listes**, éviter l'effet tableur.

Vérifier :
- Padding vertical des `ExpenseRow` ≥ 12pt.
- Espace entre les `ProjectCard` ≥ 12pt.
- Respirations autour des CTA dans les sheets.

Commit si ajustement : `style: ajustement espacements liste et cards`.

### 2.4 — Dark mode : passe dédiée
Dans le simulateur, `Cmd+Shift+A` active/bascule l'apparence.

Passer chaque écran en dark mode et vérifier :
- Contraste des textes secondaires.
- Couleur de fond des cards distincte du fond général.
- Dégradé de `BalanceBanner` reste lisible.
- Emojis restent visibles (pas d'aplat qui les efface).

Commit : `style: ajustements dark mode par écran`.

### 2.5 — États vides (empty states)
Pour chaque liste vide, vérifier qu'il y a :

- Une illustration ou SF Symbol large (≥ 60pt).
- Un titre clair.
- Un sous-titre court.
- Un CTA primaire visible.

Écrans concernés :
- `ProjectListView` (aucun projet)
- `ProjectDetailView` (aucune dépense)

Commit si écart : `style: uniformisation empty states`.

### 2.6 — Localisation FR / EN complète
- Vérifier que tous les textes en dur passent par le String Catalog (`.xcstrings`).
- `LocalizedStringKey` systématique dans les vues.
- Lancer l'app en EN (simulateur : Settings → General → Language & Region → English).
- Prendre des notes sur les éventuels manques.
- Commit : `fix: localisation EN des textes manquants`.

**Commande simulateur pour basculer la langue**
```bash
xcrun simctl spawn booted defaults write -g AppleLanguages -array en
xcrun simctl spawn booted defaults write -g AppleLocale en_US
xcrun simctl shutdown booted && xcrun simctl boot <UUID>
```

---

# Sprint 3 — Amélioration graphique (polish esthétique)

**Objectif** : l'app passe du « fonctionnel » au « désirable ». C'est ici qu'on investit sur l'identité visuelle.

**Durée estimée** : 2 à 4 sessions (optionnelle avant release).

**⚠️ Règle d'arbitrage** : si le planning serre, sauter ce sprint et aller direct à Sprint 4. Le design actuel est « bon enough » pour une v1. La boucle feedback utilisateur post-launch est plus précieuse que plus de polish.

## Tâches

### 3.1 — Micro-animations de confirmation
Quand une action utilisateur réussit (ajout dépense, création projet), ajouter une confirmation subtile :

- Dépense ajoutée → petit « flash » vert sur la liste pendant 0.5s sur la nouvelle ligne.
- Balance qui change → `.contentTransition(.numericText())` déjà en place, vérifier que c'est activé partout.

Commit : `style: micro-animations de confirmation d'action`.

### 3.2 — Transition splash → liste
Vérifier que la transition du splash screen vers `ProjectListView` est fluide et n'a pas de « saut ».

Optionnel : ajouter un léger `.opacity` + `.scale` combinés.

Commit : `style: transition splash vers accueil`.

### 3.3 — Haptics cohérents
- Ajout dépense → `UINotificationFeedbackGenerator.notificationOccurred(.success)`.
- Suppression → `UIImpactFeedbackGenerator(style: .medium).impactOccurred()`.
- Toggle paywall → `.impactOccurred(style: .light)`.
- Erreur formulaire → `.notificationOccurred(.error)`.

Centraliser dans `Services/HapticService.swift` si ce n'est pas déjà fait.

Commit : `feat: centralisation des haptics dans HapticService`.

### 3.4 — Illustration d'onboarding (optionnel)
Si le temps le permet, remplacer les SF Symbols de l'onboarding par des illustrations SVG personnalisées (exportées en PDF vectoriel depuis Figma ou Sketch), placées dans l'Asset Catalog.

⚠️ Coût : 1 à 2h de design externe ou DIY. À arbitrer selon le planning.

Commit : `style: illustrations onboarding personnalisées`.

### 3.5 — Icône app : revue finale
- Vérifier que l'icône 1024×1024 est présente dans `Assets.xcassets`.
- Vérifier le rendu sur device (pas juste simulateur — le rendu des ombres peut varier).
- Vérifier qu'elle reste lisible en petite taille (Spotlight, Settings).

Si besoin d'une retouche → itérer.

Commit : `style: ajustement AppIcon v1.0`.

---

# Sprint 4 — Préparation soumission (non-code)

**Objectif** : toute la documentation légale, marketing, et technique nécessaire à la soumission est prête.

**Durée estimée** : 1 à 2 sessions.

**Definition of Done** :

- Privacy Policy publiée sur `https://beabot.fr/apps/duo-send#policy`
- Support URL active : `https://beabot.fr/apps/duo-send/`
- Screenshots FR et EN en 6,7" et 5,5" prêts dans `docs/app-store-assets/`
- Métadonnées App Store FR et EN écrites dans `docs/app-store-assets/metadata.md`
- Compte Apple Developer actif (payé 99 $/an)
- App ID créé dans Apple Developer Portal

## Tâches

### 4.1 — Compte Apple Developer
Action hors code :

1. Se connecter à [developer.apple.com](https://developer.apple.com).
2. S'enrôler dans le programme (99 $/an).
3. Attendre la validation (peut prendre 24 à 48h).
4. Noter les info dans `docs/DECISIONS.md` : date d'adhésion, ID de compte, Team ID (`66S2QLG2HD` déjà connu).

**Tâche non-code, ne pas committer.**

### 4.2 — Privacy Policy (bilingue)
- Utiliser `docs/PRIVACY_FR.md` et `docs/PRIVACY_EN.md` comme source.
- Les fusionner en une page web unique bilingue sur `beabot.fr`.
- URL finale : `https://beabot.fr/apps/duo-send#policy`.
- Tester que l'URL retourne bien un `200 OK` et que l'ancre `#policy` marche.

**Commande de test**
```bash
curl -I https://beabot.fr/apps/duo-send
```

### 4.3 — Support URL
- Page support publique : `https://beabot.fr/apps/duo-send/`.
- Doit contenir au minimum :
  - une description courte de l'app,
  - une adresse e-mail de contact,
  - un lien vers la Privacy Policy,
  - un formulaire ou lien mailto pour retours utilisateurs.
- Vérifier que le lien marche.

### 4.4 — Screenshots simulateur
Dimensions obligatoires App Store iPhone :

| Device simulateur | Dimensions exactes | Utilisation |
|---|---|---|
| iPhone 16 Pro Max (6,9") | 1320 × 2868 px portrait | Obligatoire — iPhone grand |
| iPhone 8 Plus (5,5") | 1242 × 2208 px portrait | Obligatoire — iPhone legacy |

**Série recommandée (6 captures par device, par langue)** :
1. Liste des projets avec 3–4 projets peuplés
2. Détail d'un projet avec plusieurs dépenses et balance claire
3. Ajout d'une dépense (formulaire)
4. BalanceBanner en état « équilibre » vs état « P2 doit X à P1 »
5. Écran réglages avec section Pro et export PDF
6. Onboarding ou PaywallView

**Règles** :
- Pas de placeholders vides.
- Données crédibles (prénoms FR : Léa & Tom ; prénoms EN : Emma & Jack).
- Montants réalistes (ex. Voyage Italie 847,50 €).
- Pas de barre de simulateur visible (utiliser l'option « record screen » ou screenshot plein écran).

**Commandes**
```bash
# Lister les devices dispos
xcrun simctl list devices | grep "iPhone 16 Pro Max"
xcrun simctl list devices | grep "iPhone 8 Plus"

# Screenshot en PNG dans le dossier Desktop
xcrun simctl io booted screenshot ~/Desktop/duospend_screen_01.png
```

Stocker les screenshots dans `docs/app-store-assets/screenshots/fr/6.9/`, `fr/5.5/`, `en/6.9/`, `en/5.5/`.

Commit : `docs: screenshots App Store FR et EN`.

### 4.5 — Métadonnées App Store
Créer `docs/app-store-assets/metadata.md` avec les champs :

**Pour chaque langue (FR et EN)** :

- **Nom** (30 chars max) : `DuoSpend — Budget en couple` (FR) / `DuoSpend — Couple Budget` (EN)
- **Sous-titre** (30 chars max) : `Dépenses partagées simples` (FR) / `Shared expenses made easy` (EN)
- **Mots-clés** (100 chars max, séparés par virgules, **sans espaces**) :
  - FR : `budget,couple,dépenses,partage,remboursement,mariage,voyage,emménagement,finance,duo`
  - EN : `budget,couple,expenses,sharing,split,refund,wedding,travel,moving,finance,duo`
- **Description longue** (4000 chars max) : s'inspirer de la trame dans `docs/RELEASE.md` §5.
- **Texte promotionnel** (170 chars max, modifiable sans review) : phrase d'accroche.
- **Notes de version 1.0.0** (4000 chars max) : « Première version publique de DuoSpend. » — courte et factuelle.

**Attention** : pas d'espace entre les mots-clés dans le champ `keywords`, sinon Apple les compte dans la limite de 100 caractères.

Commit : `docs: métadonnées App Store FR EN`.

### 4.6 — Catégorie App Store
Décider de la catégorie principale et secondaire :
- **Principale** : Finance
- **Secondaire** : Productivité (ou Style de vie)

Noter dans `docs/app-store-assets/metadata.md`.

### 4.7 — Classification d'âge
- Répondre au questionnaire Apple : pas de contenu mature, pas de violence, pas de jeu d'argent, pas de localisation permanente.
- Cible : **4+**.
- Noter dans `docs/app-store-assets/metadata.md`.

### 4.8 — App Preview vidéo (optionnel)
Vidéo 15–30s en portrait, sans audio parlant, montrant :
- ouverture app,
- création rapide d'un projet,
- ajout d'une dépense,
- affichage de la balance.

Format : `.mov` ou `.mp4`, codec H.264, même résolution que les screenshots du device.

⚠️ Chronophage. À arbitrer selon le planning. Souvent ajouté **après** la première release.

---

# Sprint 5 — Configuration Xcode pour Release

**Objectif** : le projet Xcode est prêt à produire une archive Release valide.

**Durée estimée** : 1 session.

**Definition of Done** :

- `Bundle Identifier` = `fr.beabot.DuoSpend` (vérifié)
- Version = `1.0.0`, Build = `1`
- Signing configuré en « Automatic » avec le Team ID
- `PrivacyInfo.xcprivacy` complet
- CloudKit entitlement **désactivé** en v1 (décision actée : `cloudKitDatabase: .none`)
- StoreKit 2 configuré avec le product ID `fr.beabot.DuoSpend.unlimitedprojects`

## Tâches

### 5.1 — Vérification Bundle ID et version
Ouvrir `DuoSpend.xcodeproj` → cible `DuoSpend` → General :
- `Bundle Identifier` : `fr.beabot.DuoSpend`
- `Version` : `1.0.0`
- `Build` : `1`

Commit `project.pbxproj` si modification : `chore: version 1.0.0 build 1`.

### 5.2 — Signing & Capabilities
- Team : `66S2QLG2HD`
- Signing : `Automatic`
- Capabilities à activer : `In-App Purchase`, `App Groups` (`group.fr.beabot.DuoSpend`).
- Capabilities à **laisser désactivées** en v1 : `iCloud` / `CloudKit`.

### 5.3 — PrivacyInfo.xcprivacy
Vérifier le contenu du fichier `DuoSpend/Resources/PrivacyInfo.xcprivacy`.

Clés attendues pour une app local-first sans tracking :
- `NSPrivacyTracking` : `false`
- `NSPrivacyTrackingDomains` : `[]` (vide)
- `NSPrivacyCollectedDataTypes` : `[]` (vide) — **à confirmer** : si on enregistre un purchaseID StoreKit, il n'est pas considéré comme « collecté » car il reste local.
- `NSPrivacyAccessedAPITypes` : liste des API sensibles utilisées (ex : `NSPrivacyAccessedAPICategoryUserDefaults` avec raison `CA92.1`).

Commit : `chore: PrivacyInfo.xcprivacy complet v1`.

### 5.4 — StoreKit configuration file
- Vérifier `DuoSpend.storekit` (fichier de test local).
- Product ID : `fr.beabot.DuoSpend.unlimitedprojects`.
- Type : Non-Consumable.
- Price : 6,99 € (ou 4,99 € en promo launch — décision à acter).

Sur App Store Connect :
- Créer le produit in-app avec le **même** product ID.
- Soumettre le produit in-app **en même temps** que le premier build (sinon il ne sera pas disponible à la review).

### 5.5 — Launch screen
Vérifier que le launch screen s'affiche correctement (souvent `SplashScreenView` fait office de pont, mais iOS affiche d'abord un storyboard ou un vrai Launch Screen natif).

- Si `LaunchScreen.storyboard` existe, vérifier qu'il est bien référencé dans `Info.plist` (`UILaunchStoryboardName`).
- Sinon, configurer un `UILaunchScreen` dict dans `Info.plist` avec la couleur de fond et l'image logo.

### 5.6 — Suppression du code debug résiduel
- Vérifier que `PaywallDebugView` et autres outils de debug sont bien **exclusivement** derrière `#if DEBUG`.
- Vérifier qu'aucune donnée de test n'est insérée en Release.

**Commande**
```bash
grep -rn "PaywallDebug\|SampleData\|DEBUG" DuoSpend --include="*.swift" | grep -v Tests
```

### 5.7 — Archive Release de test
Faire un build Release local (sans upload) pour vérifier qu'il compile :

```bash
cd /Users/benoitabot/Sites/DuoSpend
xcodebuild -scheme DuoSpend -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath ~/Desktop/DuoSpend-test.xcarchive \
  archive
```

Si ça passe sans erreur → OK. Sinon → débugger avant Sprint 6.

---

# Sprint 6 — TestFlight beta

**Objectif** : l'app tourne sur device réel, testée par au moins 2 personnes hors équipe.

**Durée estimée** : 3 à 7 jours calendaires (dépend du feedback).

**Definition of Done** :

- Build 1.0.0 (1) uploadé sur TestFlight
- Validé par Apple pour distribution TestFlight externe
- Au moins 2 testeurs externes ont installé et utilisé l'app
- Feedback critique traité (crashs, bugs bloquants) — le reste va dans `docs/TODO.md` pour v1.1

## Tâches

### 6.1 — Premier build TestFlight
1. Xcode → Product → Archive.
2. Organizer → Distribute App → App Store Connect → Upload.
3. Attendre l'email Apple « Build uploaded » (5–30 min).
4. App Store Connect → TestFlight → attendre le « Ready to test ».

### 6.2 — Test interne (soi-même + compte secondaire)
- Ajouter son propre Apple ID comme testeur interne.
- Installer via l'app TestFlight sur un iPhone physique.
- Scénario complet : onboarding → création projet → ajout dépenses → paywall → achat sandbox → widget → settings → export PDF.

### 6.3 — Test externe
- Créer un groupe « Beta externe » sur TestFlight.
- Inviter 2 à 5 personnes (amis, famille, couples cibles).
- Préparer un lien public TestFlight.
- Soumettre le build à la review TestFlight externe (Apple valide en général en <24h).

### 6.4 — Collecte feedback
Centraliser le feedback dans `docs/_scratch/beta_feedback.md` (non commité tant que pas traité).

Pour chaque retour, décider :
- `block release` → corriger avant soumission finale
- `post v1.0` → ajouter à `docs/TODO.md` post-MVP
- `wontfix` → noter la raison dans `docs/DECISIONS.md`

### 6.5 — Correctifs éventuels
Incrémenter le Build number (1 → 2, 3…) à chaque nouvel upload, **pas** la version marketing.

Commits : `fix: <retour beta …>` — tous doivent passer avant l'upload suivant.

---

# Sprint 7 — Soumission App Store

**Objectif** : l'app est en review par Apple.

**Durée estimée** : 1 session + délai Apple (1 à 3 jours typique).

**Definition of Done** :

- Version soumise à la review Apple
- Statut « Waiting for Review » puis « In Review » dans App Store Connect

## Tâches

### 7.1 — App Store Connect : fiche produit
Dans App Store Connect → App → Version 1.0.0 :

- Nom et sous-titre (FR et EN) — voir Sprint 4.5
- Description (FR et EN)
- Mots-clés (FR et EN)
- URL de promotion : `https://beabot.fr/apps/duo-send/`
- URL de support : `https://beabot.fr/apps/duo-send/`
- URL de confidentialité : `https://beabot.fr/apps/duo-send#policy`
- Catégorie : Finance / Productivité
- Screenshots uploadés : 6,7" et 5,5" en FR et EN
- Notes de version : « Première version publique. »
- Classification d'âge : 4+

### 7.2 — Section « Confidentialité des données »
Questionnaire App Store Connect :

- Collectez-vous des données ? → **Non** (app local-first sans analytics ni tracking)
- Utilisez-vous des SDKs tiers ? → **Non**
- Ce choix doit être parfaitement cohérent avec le `PrivacyInfo.xcprivacy`.

### 7.3 — In-App Purchase : soumission jointe
- Le produit `fr.beabot.DuoSpend.unlimitedprojects` doit être **attaché** à la v1.0.0 pour passer en review.
- Sans cela, l'achat ne fonctionnera pas pour les utilisateurs finaux.
- Vérifier dans App Store Connect → App → Fonctionnalités d'app → Achats intégrés → statut « Prêt à être soumis ».

### 7.4 — Informations pour la review
Dans la section « Infos pour la review » :

- Compte de démo → **non requis** (pas de login).
- Contact : nom, téléphone, email.
- Notes : mentionner que l'app est local-first, que l'achat in-app débloque les projets illimités + widgets, et que pour tester un couple il suffit d'utiliser deux prénoms dans l'onboarding.

### 7.5 — Build de soumission
- Associer le dernier build TestFlight validé à la version.
- Choisir « Publication manuelle » (on publie soi-même après validation) plutôt que « Publication auto dès validation ».
- Cliquer « Soumettre pour review ».

### 7.6 — Suivi review
- Surveiller les emails App Store Connect.
- Temps moyen de review en 2026 : 24–48h, parfois quelques heures, parfois plusieurs jours.
- Si rejet : lire attentivement les raisons dans Resolution Center, corriger, ré-uploader un nouveau build, ré-soumettre.

---

# Sprint 8 — Lancement et suivi

**Objectif** : l'app est publique sur l'App Store et on observe les premiers retours.

**Durée estimée** : ongoing, 1 à 2 semaines actives.

**Definition of Done** :

- Status « Ready for Sale » / « Disponible »
- Au moins 1 utilisateur organique (hors beta) a installé l'app
- Page `beabot.fr/apps/duo-send/` à jour avec lien App Store
- Communication externe faite (Twitter/X, LinkedIn, IndieHackers, r/iOSApps, Product Hunt si pertinent)

## Tâches

### 8.1 — Publication
Quand Apple approuve :
- App Store Connect → bouton « Publier ».
- L'app apparaît sur l'App Store sous 1 à 4 heures (propagation CDN).
- Vérifier la fiche sur iPhone.

### 8.2 — Communication minimale
- Tweet d'annonce avec screenshot principal et lien App Store.
- Post LinkedIn avec contexte : « Indie dev, app pensée local-first, 6,99 € one-time, pas d'abo, pas de pub. »
- Message personnel à 5–10 personnes proches qui pourraient aimer.
- Page `beabot.fr/apps/duo-send/` mise à jour avec badge « Download on the App Store ».

### 8.3 — Product Hunt (optionnel, à chaud)
Si tu veux tenter un lancement PH :
- Préparer la fiche 24h avant.
- Launch à 00:01 PST (9h heure française).
- Prévoir 2–3 visuels de qualité (pas seulement screenshots, un visuel produit/lifestyle aide).

### 8.4 — Monitoring App Store Connect
Chaque jour pendant 2 semaines :
- Nombre d'impressions / téléchargements.
- Nombre d'achats in-app.
- Crashes (Xcode → Organizer → Crashes).
- Avis utilisateurs et notes (répondre à tous, même les 5 étoiles).

### 8.5 — Backlog v1.1
Toutes les remontées non-critiques → `docs/TODO.md` section « v1.1 ».

Priorités connues pour v1.1 :
- Fix bugs remontés par les premiers utilisateurs.
- Activation iCloud sync (même Apple ID).
- Amélioration onboarding selon feedback.
- Éventuel ajout : recherche dans les dépenses, templates projets.

Pas de v1.1 avant 2 à 4 semaines de stabilité de la v1.0.

---

# Récapitulatif des sprints

| Sprint | Objectif | Type de travail | Priorité |
|---|---|---|---|
| 1 | Stabilisation fonctionnelle | Code | 🔴 Bloquant |
| 2 | Revue visuelle et polish UI | Code + design | 🔴 Bloquant |
| 3 | Amélioration graphique | Code + design | 🟡 Optionnel |
| 4 | Prépa soumission (non-code) | Contenu + légal | 🔴 Bloquant |
| 5 | Config Xcode pour Release | Config + code | 🔴 Bloquant |
| 6 | TestFlight beta | Release + tests | 🔴 Bloquant |
| 7 | Soumission App Store | Release | 🔴 Bloquant |
| 8 | Lancement | Marketing + suivi | 🟡 Important |

---

# Règles transverses à tous les sprints

- **Un commit = un fix ou une feature.** Pas de gros commits fourre-tout.
- **Messages de commit en français, préfixés** : `feat:`, `fix:`, `style:`, `refactor:`, `docs:`, `test:`, `chore:`.
- **Toujours builder avant de committer.**
- **Quand une tâche est terminée** : cocher dans `docs/TODO.md`.
- **Quand une décision d'archi est prise** : ajouter dans `docs/DECISIONS.md`.
- **Ne pas sauter un sprint bloquant.** Sprint 3 est le seul sautable.
- **Ne pas changer le scope v1 en cours de route.** Tout nouvel item → `docs/TODO.md` section v1.1.

---

# Points d'attention spécifiques à Codex et ChatGPT

- Codex CLI lit `AGENTS.md` à la racine du repo. Les conventions critiques y sont.
- Pour une tâche donnée, coller la section du sprint concerné dans le prompt de Codex, plus la commande de validation.
- Toujours demander à Codex de **builder et tester avant de committer** (c'est dans `AGENTS.md`).
- Si Codex propose un refactor large → refuser et recentrer sur la tâche atomique.
- Si Codex ne trouve pas un fichier → l'orienter vers `project.yml` (XcodeGen) pour comprendre la structure.

---

*Document vivant. Mettre à jour au fur et à mesure de l'avancée.*
*Dernière mise à jour : avril 2026.*
