# CLAUDE.md — DuoSpend

> App iOS de gestion de budget par projet pour couples.
> Une question, une réponse : **"Qui doit combien à qui ?"**

**Racine** : `/Users/benoitabot/Sites/DuoSpend`
**Repo** : `https://github.com/benabot/DuoSpend`
**Compte Apple** : `benoitabot@yahoo.fr` — Team ID : `66S2QLG2HD`
**Dernière mise à jour** : mars 2026

---

## 1. Stack technique

| Élément | Choix |
|---|---|
| Langage | Swift 6 (strict concurrency) |
| UI | SwiftUI — iOS 17+ |
| Persistance | SwiftData (`@Model`) |
| Sync | CloudKit automatique via SwiftData |
| Architecture | MVVM (Observation framework) |
| IDE | Xcode 16+ |
| Dépendances | **Aucune** — Apple frameworks uniquement |
| Tests | Swift Testing + XCTest (UI) |
| Distribution | App Store — iPhone uniquement (MVP) |

---

## 2. État du projet — Phases

### ✅ Phase 1 — Setup & Scaffolding
Projet Xcode créé, modèles SwiftData, structure MVVM, SampleData.

### ✅ Phase 2 — Écrans principaux
ProjectListView, ProjectCard, CreateProjectView, ProjectDetailView,
ExpenseRow, BalanceBanner, AddExpenseView, NavigationStack.

### ✅ Phase 3 — Logique métier
BalanceCalculator, BalanceResult/Status, 5 tests unitaires verts.

### ✅ Phase 4 — Polish UX
Swipe-to-delete, edit dépense/projet, dark mode, haptics,
validation formulaires, tri dépenses, formatage € locale fr_FR.

### ✅ Phase 5 — Persistance & Tests device (en cours)
SwiftData local OK. Tests device physique + iCloud sync à valider.

### ✅ Phase 6 — Design & Identité visuelle
SplashScreenView animé, design system couleurs (5 color sets),
ProjectCard redesign, BalanceBanner gradient, ExpenseRow avatars,
typographie .rounded, empty states, micro-animations, AppIcon.

### 🚧 Phase 7 — Préparation App Store (prochaine)
Screenshots, métadonnées, review guidelines, TestFlight, soumission.

### 📋 Backlog post-MVP
Templates projets, export PDF, catégories, Widgets, Charts,
Paywall StoreKit 2 (6,99€ one-time), recherche dépenses.


---

## 3. Structure du projet Xcode

```
DuoSpend/
├── CLAUDE.md                          ← ce fichier
├── SKILLS.md                          ← skill Claude.ai
├── README.md
├── project.yml                        ← XcodeGen (si utilisé)
├── docs/
│   ├── MVP.md                         ← spec fonctionnelle complète
│   ├── ARCHITECTURE.md
│   ├── DECISIONS.md
│   ├── TODO.md                        ← tâches par sprint
│   └── PROMPT_CLAUDE_CODE_*.md        ← prompts prêts à l'emploi
├── DuoSpend.xcodeproj/
└── DuoSpend/
    ├── App/
    │   └── DuoSpendApp.swift           # @main, ModelContainer
    ├── Models/
    │   ├── Project.swift
    │   ├── Expense.swift
    │   ├── PartnerRole.swift
    │   └── SplitRatio.swift
    ├── Views/
    │   ├── ProjectListView.swift
    │   ├── ProjectDetailView.swift
    │   ├── CreateProjectView.swift
    │   ├── EditProjectView.swift
    │   ├── AddExpenseView.swift
    │   ├── OnboardingView.swift
    │   ├── SplashScreenView.swift
    │   └── Components/
    │       ├── ProjectCard.swift
    │       ├── ExpenseRow.swift
    │       └── BalanceBanner.swift
    ├── ViewModels/
    │   └── ProjectDetailViewModel.swift
    ├── Services/
    │   └── BalanceCalculator.swift
    ├── Extensions/
    │   ├── Decimal+Currency.swift
    │   └── Color+DuoSpend.swift
    └── Resources/
        ├── Assets.xcassets            # 5 color sets + AppIcon
        └── PrivacyInfo.xcprivacy      # iOS 17+ requis
```

---

## 4. Modèles de données

```swift
@Model class Project {
    var name: String          // "Mariage"
    var emoji: String         // "💒"
    var budget: Decimal?
    var partner1Name: String
    var partner2Name: String
    var createdAt: Date
    @Relationship(deleteRule: .cascade)
    var expenses: [Expense] = []
}

@Model class Expense {
    var title: String
    var amount: Decimal       // JAMAIS Double
    var paidBy: PartnerRole
    var splitRatio: SplitRatio
    var date: Date
    var project: Project?
}

enum PartnerRole: String, Codable { case partner1, partner2 }

enum SplitRatio: Codable, Equatable {
    case equal
    case custom(partner1Share: Decimal, partner2Share: Decimal)
}
```


---

## 5. Design System

### Couleurs (Color+DuoSpend.swift + Assets.xcassets)

| Token | Light | Dark | Usage |
|---|---|---|---|
| `Color.accentPrimary` | violet #7C5CFC | idem | CTA, accent |
| `Color.partner1` | bleu #3B82F6 | idem | Partenaire 1 |
| `Color.partner2` | rose #F472B6 | idem | Partenaire 2 |
| `Color.cardBackground` | blanc | gris sombre | Cards |
| `Color.successGreen` | vert #22C55E | idem | Équilibre |

### Typographie
- Montants, soldes → `.rounded` design → `Font.system(.title, design: .rounded)`
- Titres section → `.headline`
- Corps → `.body` (system)
- Labels secondaires → `.caption` + `.secondary`

### Animations
- Listes → `.spring(response: 0.4, dampingFraction: 0.8)`
- Montants → `.contentTransition(.numericText())`
- Sheets → `.presentationCornerRadius(20)` + `.presentationDetents`
- Splash → scale + bounce + fade, 2s, puis transition vers ProjectListView

### Composants clés
- **ProjectCard** : emoji dans cercle teinté, ProgressView budget, balance colorée
- **BalanceBanner** : LinearGradient, texte blanc, flèche entre noms
- **ExpenseRow** : avatar 36pt initiale payeur sur fond coloré
- **Empty states** : `heart.circle.fill` 60pt + `.symbolEffect(.pulse)`

---

## 6. Conventions de code Swift

### Nommage
- Types → `PascalCase`
- Propriétés/méthodes → `camelCase`
- Fichier = nom du type principal
- Views → suffixe `View` ; ViewModels → suffixe `ViewModel`
- Composants réutilisables → sans suffixe (`ProjectCard`, `BalanceBanner`)

### SwiftUI
- `@Observable` (Observation framework) — jamais `ObservableObject`
- `@Bindable` pour les bindings dans les vues
- Sous-vue > 40 lignes → extraire dans `Components/`
- Vue > 150 lignes → refactoriser
- Modifiers : layout → apparence → interaction → accessibility

### SwiftData
- `@Model` sur classes de données uniquement
- Relations → `@Relationship` explicite
- Lectures → `@Query` dans les vues
- CRUD → `ModelContext` dans les ViewModels
- Zéro logique métier dans les modèles

### Qualité
- `///` doc comment sur types et fonctions publics
- Jamais `!` force unwrap (sauf `Preview Content/`)
- Jamais `print()` → utiliser `os.Logger`
- `guard` early return vs `if` imbriqués
- Erreurs → `enum DuoSpendError: LocalizedError`
- Montants → **toujours `Decimal`**, jamais `Double`

---

## 7. Commandes utiles

```bash
# Ouvrir Xcode
open /Users/benoitabot/Sites/DuoSpend/DuoSpend.xcodeproj

# Build (filtré)
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E 'error:|warning:|BUILD'

# Tests
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test 2>&1 | grep -E 'passed|failed|error'

# Clean
xcodebuild -scheme DuoSpend clean

# Git — convention commits
git commit -m "feat: ..."     # nouvelle feature
git commit -m "fix: ..."      # correction bug
git commit -m "style: ..."    # design/UI sans logique
git commit -m "refactor: ..."
git commit -m "docs: ..."
git commit -m "test: ..."
```


---

## 8. Workflow Claude Code / Codex

### Avant de coder
1. Lire ce `CLAUDE.md` → conventions et état du projet
2. Lire `docs/TODO.md` → tâche en cours du sprint actuel
3. Lire `docs/MVP.md` → spec fonctionnelle si besoin
4. Vérifier `docs/DECISIONS.md` → ne pas contredire les décisions actées

### Pendant le code
- Un commit = une feature ou un fix
- Messages en français, préfixés (`feat:`, `fix:`, `style:`, etc.)
- Toujours builder avant de committer

### Après le code
- Cocher la tâche dans `docs/TODO.md`
- Si décision d'archi prise → ajouter dans `docs/DECISIONS.md`
- Si nouveau composant/pattern → documenter ici

### Prompts prêts à l'emploi
Voir `docs/PROMPT_CLAUDE_CODE_*.md` pour des prompts copy-paste
directement dans Claude Code depuis `/Users/benoitabot/Sites/DuoSpend`.

---

## 9. Roadmap commercialisation App Store

### Phase 7 — Préparation soumission (priorité actuelle)

| Tâche | Détail |
|---|---|
| Screenshots | 6,7" (iPhone 16 Pro Max) + 5,5" (iPhone 8+) obligatoires |
| App Preview | Vidéo 30s optionnelle mais recommandée |
| Métadonnées | Nom, sous-titre, description FR+EN, mots-clés (100 chars max) |
| Privacy Policy | URL requise si iCloud/CloudKit utilisé |
| Support URL | Obligatoire |
| TestFlight | Beta interne → externe avant soumission |
| Review guidelines | Pas de contenu de compte requis, données locales ✅ |

### Checklist technique App Store
- [ ] Bundle ID : `fr.benabot.DuoSpend` (vérifier dans Xcode)
- [ ] Version : 1.0.0 / Build : 1
- [ ] Entitlements CloudKit configurés
- [ ] PrivacyInfo.xcprivacy complet
- [ ] Icône app toutes tailles (1024×1024 requis)
- [ ] Pas de symboles manquants en Release
- [ ] Archive Release → Validate → Distribute

### Monétisation
- **MVP v1.0** : gratuit, sans limite, sans pub, sans tracking
- **v2 Premium** : 6,99€ one-time via StoreKit 2
  - Projets illimités (v1 = 3 projets max)
  - Templates projets (mariage, voyage, bébé…)
  - Export PDF récapitulatif
- Zéro abonnement, zéro pub, zéro données collectées

### ASO (App Store Optimization)
- **Nom** : DuoSpend — Budget en couple
- **Sous-titre** : Dépenses partagées simplifiées
- **Mots-clés cibles** : budget couple, dépenses partagées, partage frais,
  remboursement, mariage budget, voyage budget, finance couple

---

## 10. Principes directeurs

1. **Local-first** — tout fonctionne hors ligne, iCloud = bonus
2. **Zéro dépendance** — Apple frameworks uniquement
3. **Privacy by design** — aucune donnée ne quitte l'appareil (sauf iCloud user)
4. **Simple > Complet** — moins de features, mieux exécutées
5. **Éco-conception** — code efficient, pas de superflu, images optimisées
6. **Couple uniquement** — toujours 2 partenaires, jamais de groupe
