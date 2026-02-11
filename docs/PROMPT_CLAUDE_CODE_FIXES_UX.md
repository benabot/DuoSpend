# Prompt Claude Code — Fixes UX + Interface fun

> Copie-colle ce prompt dans Claude Code depuis `~/Sites/DuoSpend`

---

## Contexte

Lis `CLAUDE.md`. L'app compile et tourne, mais l'interface est terne et le formulaire de création a des problèmes UX. L'objectif : une app que tu as **envie d'ouvrir**, colorée, vivante, joyeuse — pas un tableur gris.

---

## Partie 1 — Fixes UX urgents

### 1. CreateProjectView — Emoji picker visuel

Le TextField emoji est incompréhensible (on dirait un 2ème champ budget). Remplace-le par une **grille d'emojis cliquables** :

```
💒 🏖️ 🏠 👶 🚗 🎄 🎂 🍽️ 💰 🛒 🎓 ✈️ 🏥 🐶 🎁
```

- `LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5))`
- Emoji sélectionné : fond cercle `.accentPrimary.opacity(0.2)` + scale 1.2
- Défaut : 💰
- Animation `.spring()` au tap

### 2. Sheets en plein écran

Toutes les sheets (Create, Add, Edit) : `.presentationDetents([.large])` uniquement. Plus de `.medium`, ça tronque et c'est flou derrière.

### 3. Placeholders inspirants

- Nom du projet : `"Voyage à Rome, Mariage, Bébé..."`
- Partenaire 1 : `"Prénom (ex: Marie)"`
- Partenaire 2 : `"Prénom (ex: Thomas)"`
- Budget : ajouter un caption en dessous : `"Optionnel · Laissez vide si pas de limite"`

### 4. Bouton retour

Vérifie que le `NavigationLink` dans `ProjectListView` fonctionne : quand on tap sur une card, on doit arriver dans `ProjectDetailView` **avec** la flèche retour `< DuoSpend`. S'il n'y a pas de bouton retour, cherche un `NavigationStack` dupliqué et corrige.

---

## Partie 2 — Rendre l'app FUN

L'app est fonctionnelle mais **terne, grise, fade**. Un couple qui ouvre ça ne va pas sourire. Voici les améliorations :

### 5. Fond d'écran coloré

Remplace le fond gris système par un **fond très légèrement teinté** :
- Light mode : un blanc chaud/crème `Color(red: 0.98, green: 0.97, blue: 0.95)` ou un très léger gradient vertical (blanc → crème)
- Dark mode : garder le noir système
- Applique-le sur `ProjectListView` et `ProjectDetailView` via `.scrollContentBackground(.hidden)` + `.background()`

### 6. ProjectCard vivante

La card actuelle est plate et morte. Refacto complète :
- Fond blanc pur (light) / gris foncé (dark) avec **coins arrondis 20pt**
- **Ombre colorée** : `.shadow(color: Color.accentPrimary.opacity(0.08), radius: 12, y: 6)`
- Layout horizontal : emoji GROS (40pt) à gauche dans un cercle teinté → infos à droite
- Nom du projet en `.title3.bold()` + design `.rounded`
- Sous le nom : montant dépensé en `.caption` + couleur secondaire
- En bas : la balance en couleur partenaire (bleu/rose/vert) avec une petite icône
- **Padding interne 16pt**, le tout dans un fond qui n'est PAS le style List par défaut
- Utilise `.listRowBackground(Color.clear)` + `.listRowSeparator(.hidden)` pour virer le style liste moche
- Chaque card doit ressembler à une carte d'une app moderne (pense Revolut, N26)

### 7. BalanceBanner — Hero visuel

Le banner doit être le **hero** de l'écran detail, pas un bloc timide :
- **Grand gradient vibrant** sur toute la largeur, coins arrondis 20pt
- Gradient partner1 : `LinearGradient(colors: [.partner1, .partner1.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)`
- Gradient partner2 : idem avec `.partner2`
- Gradient balanced : utiliser un vert → teal joyeux
- **Montant XXL** : `.font(.system(size: 42, weight: .bold, design: .rounded))` en blanc
- Texte "X doit ... à Y" en blanc `.opacity(0.9)`
- Icône animée : `arrow.right` qui pulse doucement entre les deux noms
- **Padding 24pt**, le tout doit en imposer visuellement

### 8. ExpenseRow — Plus d'énergie

- Avatar 40pt (pas 36) avec initiale en `.system(.body, design: .rounded).bold()` blanc sur fond partenaire
- Titre de la dépense en `.body.weight(.medium)`
- Date en `.caption2` secondaire
- Montant à droite en `.system(.body, design: .rounded).bold()` avec la couleur du partenaire qui a payé
- Ajouter un petit indicateur de split si != 50/50 : petite pastille `"70/30"` en `.caption2` fond gris

### 9. Empty state joyeux

L'empty state doit donner envie de créer un projet :
- Icône : `heart.circle.fill` en 70pt, couleur `.accentPrimary`, avec `.symbolEffect(.bounce)` au lieu de `.pulse`
- Titre : **"À deux, c'est mieux !"** en `.title2.bold()` design `.rounded`
- Sous-titre : `"Créez votre premier projet et\nsuivez vos dépenses ensemble 💕"` en `.body` secondaire
- Bouton : **"C'est parti !"** au lieu de "Créer un projet" — en `.borderedProminent` arrondi, gros (`controlSize(.large)`)
- Petit rebond `.spring()` sur le bouton quand l'écran apparaît

### 10. Navigation title stylé

- `ProjectListView` : remplace le `.navigationTitle("DuoSpend")` par un titre custom avec le nom en `.system(.largeTitle, design: .rounded).bold()` et une couleur `.accentPrimary`
- Utilise `.toolbar { ToolbarItem(placement: .principal) { ... } }` si besoin pour un titre custom

### 11. Couleur d'accent système

Dans `Assets.xcassets/AccentColor.colorset`, mets la couleur `AccentPrimary` (#6C5CE7) pour que tous les éléments système (liens, boutons, toggles) utilisent cette couleur automatiquement.

### 12. Animations de vie

- Quand on ajoute une dépense et revient au detail : la nouvelle row apparaît avec `.transition(.move(edge: .top).combined(with: .opacity))`
- Quand on crée un projet et revient à la liste : la nouvelle card apparaît avec un bounce
- Le DisclosureGroup "Résumé" s'ouvre avec `.animation(.spring())`
- La barre de contribution % dans le résumé s'anime au chargement (de 0% → valeur réelle)

---

## Contraintes

- Zéro dépendance tierce — uniquement SwiftUI natif
- iOS 17+
- Dark mode doit rester parfait
- `xcodebuild build` doit passer
- Les 5 tests existants doivent passer
- Respecter les conventions de `CLAUDE.md`
