# CLAUDE.md — DuoSpend

App iOS de gestion de budget par projet pour couples.
Question centrale : « Qui doit combien à qui ? »

## Invariants produit
- 2 partenaires uniquement. Jamais de groupes.
- Local-first : l’app doit fonctionner hors ligne.
- Privacy by design : aucune donnée tierce ; iCloud/CloudKit seulement pour la sync utilisateur.
- Simple > complet : privilégier la clarté et la fiabilité au volume de fonctionnalités.

## Stack imposée
- Swift 6
- SwiftUI
- SwiftData
- iOS 17+
- MVVM + Observation framework
- Dépendances externes interdites (frameworks Apple uniquement)
- iPhone uniquement pour le MVP

## Règles métier
- Tous les montants sont en `Decimal`. Jamais `Double`.
- La logique métier reste dans `Services/` et les `ViewModels/`, pas dans les vues ni les modèles.
- Les modèles SwiftData utilisent `@Model`.
- Les relations SwiftData doivent être explicites.
- Les lectures de données se font avec `@Query` dans les vues.
- Les opérations CRUD passent par `ModelContext`.

## Conventions Swift / SwiftUI
- `@Observable`, jamais `ObservableObject`
- `@Bindable` pour les bindings
- Pas de `!` hors previews
- Pas de `print()` ; utiliser `os.Logger`
- Préférer `guard` aux imbrications
- Ajouter `///` sur les types et fonctions publics
- Nommage : types en PascalCase, membres en camelCase
- Une sous-vue > 40 lignes doit être extraite
- Une vue > 150 lignes doit être refactorisée

## Localisation
- Le target app utilise `DuoSpend/Resources/Localizable.xcstrings`.
- Le target widget utilise son propre catalogue `DuoSpendWidget/Localizable.xcstrings`.
- Toute chaîne visible dans WidgetKit (`Text`, `description`, `IntentDescription`, état verrouillé, libellés de balance) doit être ajoutée au catalogue du widget, pas à celui de l’app.
- Toute correction de localisation paywall/widget doit ajouter ou mettre à jour un test de catalogue dans `DuoSpendTests` pour éviter une régression silencieuse.

## Flux de travail
Avant de coder :
1. Lire `docs/TODO.md` pour la tâche en cours
2. Lire `docs/DECISIONS.md` si la tâche touche l’architecture ou un pattern existant
3. Lire `docs/MVP.md` seulement si la spec fonctionnelle est utile

Pendant :
- Un commit = une feature ou un fix
- Messages de commit : `feat:`, `fix:`, `style:`, `refactor:`, `docs:`, `test:`
- Builder avant commit

Après :
- Mettre à jour `docs/TODO.md` si la tâche est terminée
- Ajouter une entrée dans `docs/DECISIONS.md` si une décision d’architecture est prise

## Monétisation

Voir `docs/COMMERCIAL.md` (section 5 — Roadmap business & pricing).

## Références à charger seulement si la tâche l’exige
- `docs/MVP.md` : spécification fonctionnelle
- `docs/DECISIONS.md` : décisions d’architecture
- `docs/TODO.md` : plan de travail courant
- `docs/RELEASE.md` : App Store, TestFlight, métadonnées, screenshots
- `docs/DESIGN.md` : design system, couleurs, composants UI
- `docs/COMMERCIAL.md` : roadmap, ASO, monétisation

## À ne pas dupliquer ici
Ne pas recopier :
- l’arborescence complète du projet
- le code des modèles déjà présents dans le repo
- les checklists App Store
- la roadmap détaillée
- les commandes shell longues
- les états de phase datés
