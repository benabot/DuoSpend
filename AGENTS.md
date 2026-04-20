# AGENTS.md — DuoSpend

> Guide d'exécution pour les agents IA (Codex, ChatGPT, Claude Code, Aider, etc.).
> Ce fichier est lu **avant toute tâche**. Il ne remplace pas `CLAUDE.md` qui porte le contexte produit complet ; il le précise pour un usage agent.

---

## 1. Contexte en une phrase

App iOS native pour couples : suivre les dépenses d'un projet commun et savoir en permanence **qui doit combien à qui**. Swift 6, SwiftUI, SwiftData, iOS 17+, iPhone uniquement, zéro dépendance tierce.

---

## 2. Avant de commencer une tâche

Lire **dans cet ordre** :

1. Ce fichier (`AGENTS.md`)
2. `CLAUDE.md` — conventions produit et code
3. `docs/ROADMAP_RELEASE.md` — plan d'exécution jusqu'à l'App Store
4. `docs/TODO.md` — tâche en cours
5. `docs/DECISIONS.md` — décisions d'architecture à ne pas contredire

À charger **uniquement si la tâche l'exige** :

- `docs/DESIGN.md` — si la tâche touche l'UI
- `docs/MVP.md` — si la tâche nécessite une décision produit nouvelle
- `docs/ARCHITECTURE.md` — si la tâche touche l'archi
- `docs/COMMERCIAL.md` — si la tâche touche ASO, pricing, positionnement
- `docs/RELEASE.md` — si la tâche concerne App Store Connect

**Ne pas charger** par défaut : `OLD_CLAUDE.md`, `PROMPT_CLAUDE_CODE_*.md`, `WEBSITE_*.md`.

---

## 3. Invariants produit (non négociables)

- 2 partenaires uniquement. Jamais de groupes.
- Local-first. L'app doit fonctionner hors ligne.
- Privacy by design. Aucun tracker, aucun SDK tiers, aucune collecte.
- Simple > complet. Privilégier la clarté à la densité de features.
- iPhone uniquement pour le MVP (v1.0).

---

## 4. Stack imposée (ne pas dévier)

| Élément | Choix |
|---|---|
| Langage | Swift 6 (strict concurrency) |
| UI | SwiftUI |
| Cible | iOS 17+ |
| Persistance | SwiftData (`@Model`) |
| Architecture | MVVM + Observation framework |
| Dépendances | **Aucune** — Apple frameworks uniquement |
| Tests | Swift Testing + XCTest (UI) |
| IAP | StoreKit 2 |
| Distribution | App Store |

**Interdictions strictes** :

- Pas d'`ObservableObject` (utiliser `@Observable`).
- Pas de `print()` (utiliser `os.Logger`).
- Pas de force unwrap `!` hors `Preview Content/`.
- Pas de `Double` pour un montant métier (toujours `Decimal`).
- Pas de dépendance externe (Swift Package Manager compris) sans décision explicite actée dans `DECISIONS.md`.
- Pas de logique métier dans les vues ni les modèles.

---

## 5. Commandes de validation

Chaque tâche qui touche le code doit passer ces commandes avant commit.

### Build (rapide, scheme Debug)

```bash
cd /Users/benoitabot/Sites/DuoSpend
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build 2>&1 | grep -E '^.*(error:|BUILD)' | grep -v appintents
```

Objectif : ligne `BUILD SUCCEEDED` en sortie, zéro `error:`.

### Tests

```bash
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  test 2>&1 | grep -E 'passed|failed|error'
```

Objectif : aucun `failed`, tous `passed`.

### Build Release (avant Sprint 5)

```bash
xcodebuild -scheme DuoSpend -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath /tmp/DuoSpend.xcarchive \
  archive
```

---

## 6. Workflow commit

**Un commit = une tâche atomique.** Jamais de gros commit qui mélange refactor + feature + fix.

Préfixes obligatoires (en français) :

- `feat:` — nouvelle fonctionnalité
- `fix:` — correction de bug
- `style:` — modifications UI/CSS/design sans changement logique
- `refactor:` — réécriture sans changement de comportement
- `docs:` — documentation uniquement
- `test:` — tests uniquement
- `chore:` — maintenance, config, outillage

Exemple : `fix: suppression du flash onboarding au premier lancement`.

**Avant commit** :
- Build OK (commande §5).
- Tests OK (commande §5).
- Pas de fichier de debug non intentionnel (`.DS_Store`, `*.xcuserdatad`, dumps…).

**Après commit** :
- Cocher la tâche dans `docs/TODO.md`.
- Si décision d'architecture nouvelle → ligne ajoutée dans `docs/DECISIONS.md`.
- Si nouveau pattern réutilisable → documenter dans `CLAUDE.md`.

---

## 7. Structure du repo (pour s'orienter vite)

```
DuoSpend/
├── AGENTS.md                  ← ce fichier (entrée agent)
├── CLAUDE.md                  ← conventions produit et code
├── README.md                  ← description repo humaine
├── project.yml                ← XcodeGen (génère .xcodeproj)
├── .codex/                    ← config locale Codex (optionnelle)
├── docs/
│   ├── ROADMAP_RELEASE.md     ← plan d'exécution jusqu'à l'App Store
│   ├── TODO.md                ← tâche en cours
│   ├── DECISIONS.md           ← décisions d'archi
│   ├── MVP.md                 ← spec produit complète
│   ├── ARCHITECTURE.md
│   ├── DESIGN.md
│   ├── RELEASE.md
│   ├── COMMERCIAL.md
│   ├── PRIVACY_FR.md
│   ├── PRIVACY_EN.md
│   └── app-store-assets/      ← screenshots et métadonnées
├── DuoSpend.xcodeproj/
└── DuoSpend/
    ├── App/                   # DuoSpendApp.swift, ModelContainer
    ├── Models/                # Project, Expense, PartnerRole, SplitRatio
    ├── Views/                 # Écrans et Components/
    ├── ViewModels/
    ├── Services/              # BalanceCalculator, StoreManager, HapticService
    ├── Extensions/
    └── Resources/             # Assets.xcassets, PrivacyInfo.xcprivacy
```

---

## 8. Règles de découpage de code

- Sous-vue SwiftUI > 40 lignes → extraire dans `Views/Components/`.
- Vue > 150 lignes → refactoriser.
- Un ViewModel n'existe que si l'écran a une vraie orchestration.
- Un composant réutilisable a une seule responsabilité.
- Nommage : types en `PascalCase`, membres en `camelCase`, fichier = nom du type principal.
- Vues → suffixe `View` (`ProjectListView`), composants réutilisables sans suffixe (`ProjectCard`, `BalanceBanner`).

---

## 9. Règles métier critiques

- Les montants sont toujours en `Decimal`.
- La logique de balance (« qui doit combien à qui ») vit **uniquement** dans `Services/BalanceCalculator.swift`.
- Les relations SwiftData sont explicites (`@Relationship`).
- La mutation SwiftData passe par `ModelContext`, jamais directement par les modèles.
- Le pattern correct pour ajouter une dépense est `project.expenses.append(expense)` — **pas** `expense.project = project` + `modelContext.insert(expense)`.

---

## 10. Limites strictes pour les agents

**Un agent ne doit jamais** :

- Ajouter une dépendance externe sans qu'une tâche explicite le demande.
- Modifier `project.yml` ou `project.pbxproj` sans raison claire.
- Changer la version ou le bundle ID sans task dédiée (Sprint 5).
- Supprimer ou renommer des fichiers sans mention explicite.
- Toucher à `Preview Content/` hors d'une tâche de preview.
- Remettre en cause une décision listée dans `DECISIONS.md`.
- Réécrire `CLAUDE.md`, `AGENTS.md` ou `ROADMAP_RELEASE.md` en même temps qu'une tâche de code.

**Un agent doit toujours** :

- Demander confirmation avant une action destructive (suppression en masse, reset, rebase).
- Annoncer ce qu'il va faire avant de le faire si la tâche touche > 3 fichiers.
- Builder avant de committer.
- Produire des commits séparés pour des changements de nature différente.

---

## 11. Tâche en cours

La tâche active est toujours dans `docs/TODO.md` (première ligne non cochée).

Après achèvement, cocher et passer à la suivante.

Si la roadmap n'indique pas clairement la tâche active, lire `docs/ROADMAP_RELEASE.md` et identifier le premier sprint dont la Definition of Done n'est pas atteinte.

---

## 12. Quand demander à un humain

- La tâche implique une décision produit hors du scope v1.
- La tâche nécessite un secret (token, mot de passe Apple ID, clé API).
- La tâche demande une action sur App Store Connect ou Apple Developer (comptes humains, non automatisables).
- Le build échoue pour une raison hors du périmètre de la tâche.
- Un test existant casse et la raison n'est pas évidente.

Dans ces cas : **ne pas forcer**. Documenter la situation dans le prompt suivant et attendre l'humain.

---

## 13. Agents locaux Codex

Le projet peut embarquer des agents et des skills **locaux** dans `./.codex/`.
Ils complètent `AGENTS.md` et `CLAUDE.md`, mais ne les remplacent pas.

### Règle de priorité

En cas de conflit :
1. `CLAUDE.md`
2. `AGENTS.md`
3. `.codex/agents/*`
4. `.codex/skills/*`

### Quand utiliser les agents locaux

Utiliser d'abord les agents locaux pour toute tâche qui touche :
- SwiftUI, SwiftData, StoreKit 2, WidgetKit ;
- l'architecture DuoSpend ;
- la logique métier du couple à 2 ;
- les conventions de repo et le workflow de validation.

Utiliser des skills globales seulement pour les sujets **génériques** : Git, shell, rédaction de commit, conventions Markdown, CI/CD transversale, refactoring non spécifique à DuoSpend.

### Répertoire attendu

```text
.codex/
├── config.toml
├── agents/
│   ├── ios-feature-implementer.md
│   ├── swiftdata-reviewer.md
│   ├── storekit-paywall-agent.md
│   └── appstore-release-agent.md
└── skills/
    ├── duospend-architecture.md
    ├── duospend-ui.md
    ├── duospend-monetization.md
    └── duospend-testing.md
```

### Contrat des agents locaux

Chaque agent local doit :
- lire `AGENTS.md` puis `CLAUDE.md` avant d'agir ;
- respecter les invariants produit et techniques ;
- annoncer les fichiers modifiés si la tâche touche plus de 3 fichiers ;
- proposer des changements atomiques ;
- rappeler les commandes de build/test avant clôture.

Chaque agent local ne doit jamais :
- contourner une décision de `docs/DECISIONS.md` ;
- introduire une dépendance externe ;
- déplacer la logique métier hors des `Services/` ;
- créer une divergence entre code, docs et roadmap sans le signaler.

### Inventaire des agents

#### `ios-feature-implementer`
Pour implémenter un écran, un flow ou un composant SwiftUI/SwiftData conforme à DuoSpend.

#### `swiftdata-reviewer`
Pour relire ou corriger la modélisation SwiftData, les relations, les mutations `ModelContext` et les erreurs d'architecture MVVM.

#### `storekit-paywall-agent`
Pour tout ce qui concerne la limite free/pro, StoreKit 2, restore purchase et paywall.

#### `appstore-release-agent`
Pour préparer metadata, screenshots, privacy text, checklist TestFlight et cohérence App Store.

---

*Document vivant. Si une règle ici entre en conflit avec `CLAUDE.md`, `CLAUDE.md` fait foi pour le produit et `AGENTS.md` fait foi pour l'exécution agent.*
