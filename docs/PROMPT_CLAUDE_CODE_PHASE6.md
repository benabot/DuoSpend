# Prompt Claude Code — Phase 4 (fin) + Phase 6 Design

> Copie-colle ce prompt dans Claude Code depuis `~/Sites/DuoSpend`

---

## Contexte

Lis `CLAUDE.md` pour les conventions et `docs/TODO.md` pour l'état du projet.
Les phases 1-3 sont terminées. La Phase 4 est quasi finie, il reste 3 items. On enchaîne ensuite sur la Phase 6 (Design & Identité visuelle).

---

## Partie A — Fin de Phase 4 (3 items restants)

### 1. Animations de transition sheets

Ajoute des transitions `.spring()` sur les `.sheet()` de `CreateProjectView`, `AddExpenseView` et `EditProjectView`. Utilise `.presentationDetents([.medium, .large])` là où c'est pertinent pour un effet plus moderne.

### 2. Tri des dépenses

Dans `ProjectDetailView`, ajoute un `Picker` dans la toolbar (menu `...`) pour trier les dépenses :
- Par date (plus récentes d'abord) — **défaut**
- Par montant (plus gros d'abord)
- Par payeur

Stocke le choix dans un `@State` local.

### 3. Formatage montants EUR

Vérifie que `Decimal+Currency.swift` utilise bien `Locale(identifier: "fr_FR")` pour forcer le format français : `1 234,56 €`. Si le formateur utilise `Locale.current`, remplace par une locale FR explicite pour garantir le placement du symbole €.

---

## Partie B — Phase 6 : Design & Identité visuelle

C'est la partie la plus importante. L'app est fonctionnelle mais **terne**. L'objectif est de la rendre **fun, chaleureuse, moderne** — une app qu'un couple aurait plaisir à ouvrir.

### 1. Splash screen animé

Crée `SplashScreenView.swift` dans `Views/` :
- Fond blanc/très clair
- Le titre "DuoSpend" apparaît au centre avec une animation :
  - Scale de 0.5 → 1.0 avec `.spring(response: 0.6, dampingFraction: 0.6)`
  - Fade-in simultané
  - Un emoji 💕 ou une icône cœur apparaît juste en dessous avec un léger délai (0.3s)
- Après ~2s, transition automatique vers `ProjectListView` avec un fade-out
- Modifie `DuoSpendApp.swift` pour afficher `SplashScreenView` d'abord, puis basculer vers `ProjectListView` via un `@State` + `if/else` + `.animation`

### 2. Palette de couleurs

Crée des Color Sets dans `Assets.xcassets` :
- `AccentPrimary` : un violet/indigo vif (#6C5CE7 ou similaire) — couleur principale de l'app
- `Partner1Color` : bleu chaleureux (#0984E3)
- `Partner2Color` : rose/corail (#E84393)
- `CardBackground` : gris très clair en light mode (#F8F9FA), gris foncé en dark (#1C1C1E)
- `SuccessGreen` : vert doux (#00B894)

Crée une extension `Color+DuoSpend.swift` dans `Extensions/` pour y accéder facilement :
```swift
extension Color {
    static let accentPrimary = Color("AccentPrimary")
    static let partner1 = Color("Partner1Color")
    static let partner2 = Color("Partner2Color")
    static let cardBackground = Color("CardBackground")
    static let successGreen = Color("SuccessGreen")
}
```

Remplace toutes les utilisations de `.blue` par `.partner1`, `.pink` par `.partner2`, `.green` par `.successGreen` dans toutes les vues.

### 3. ProjectCard redesign

Refacto `ProjectCard.swift` :
- Fond `.cardBackground` avec `RoundedRectangle(cornerRadius: 16)`
- Ombre douce : `.shadow(color: .black.opacity(0.06), radius: 8, y: 4)`
- Emoji en taille `.title` dans un cercle coloré léger
- Si le projet a un budget, afficher une mini `ProgressView` horizontale sous le nom
- Le texte de balance en bas avec la pastille de couleur partenaire
- Padding interne généreux (16pt)

### 4. BalanceBanner redesign

Refacto `BalanceBanner.swift` :
- Remplacer le fond `.opacity(0.1)` par un `LinearGradient` :
  - P2 doit à P1 : gradient `.partner1` → `.partner1.opacity(0.7)`
  - P1 doit à P2 : gradient `.partner2` → `.partner2.opacity(0.7)`
  - Équilibre : gradient `.successGreen` → `.successGreen.opacity(0.7)`
- Texte en blanc sur le gradient (`.foregroundStyle(.white)`)
- Montant en `.font(.system(.title, design: .rounded))` + `.bold()`
- Ajouter une icône SF Symbol : `arrow.right` entre les deux noms quand quelqu'un doit de l'argent
- Coins arrondis 16pt

### 5. ExpenseRow amélioré

Refacto `ExpenseRow.swift` :
- Remplacer le `Circle().fill(payerColor).frame(width: 10)` par un avatar :
  - Cercle 36pt avec la couleur du partenaire
  - Initiale du nom du payeur en blanc au centre (`.font(.system(.caption, design: .rounded)).bold()`)
- Montant en `.font(.system(.body, design: .rounded)).fontWeight(.semibold)`
- Espacement vertical plus aéré (padding 8pt vertical)

### 6. Typographie

Applique `.font(.system(.xxx, design: .rounded))` sur :
- Tous les montants affichés (formattedCurrency)
- Les titres de navigation
- Les compteurs (nombre de dépenses)

Le reste du texte garde le design par défaut.

### 7. Empty state amélioré

Dans `ProjectListView`, remplace le `ContentUnavailableView` :
- Icône plus grande : `Image(systemName: "heart.circle.fill")` en taille 60pt, couleur `.accentPrimary`
- Animation de pulse subtile sur l'icône (`.symbolEffect(.pulse)` si iOS 17+)
- Texte principal : "Votre premier projet à deux" (plus engageant que "Aucun projet")
- Sous-texte : "Mariage, voyage, déménagement… suivez vos dépenses ensemble."
- Bouton "Créer un projet" avec `.buttonStyle(.borderedProminent)` et `tint(.accentPrimary)`

### 8. Micro-animations

- **Cards en liste** : ajoute `.transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))` + `.animation(.spring(), value: projects.count)` sur la liste de projets
- **BalanceBanner** : `.contentTransition(.numericText())` sur le montant pour animer les changements
- **Bouton +** : un léger `.scaleEffect` au tap
- **Sheets** : `.presentationCornerRadius(20)` sur toutes les sheets

### 9. Section résumé dans ProjectDetail

Ajoute une `Section("Résumé")` en haut de `ProjectDetailView` (après le BalanceBanner) avec un `DisclosureGroup` repliable contenant :
- Total dépensé par partenaire 1 : `xxx €`
- Total dépensé par partenaire 2 : `xxx €`
- Nombre de dépenses : P1 = x, P2 = y
- % de contribution de chacun (barre horizontale colorée)

Toutes ces données sont déjà dans `BalanceResult`.

### 10. Icône d'app

Crée un fichier SVG ou utilise SF Symbols pour générer une icône d'app :
- Concept : deux cœurs qui se chevauchent avec un symbole €
- Couleurs : utilise `AccentPrimary` + `Partner2Color`
- Exporte en 1024x1024 PNG et place-le dans `Assets.xcassets/AppIcon.appiconset/`
- Mets à jour le `Contents.json` correspondant

Si tu ne peux pas générer d'image, crée au minimum une icône programmatique avec SwiftUI (Canvas ou Shape) et documente comment l'exporter.

---

## Contraintes

- Respecter toutes les conventions de `CLAUDE.md`
- Zéro dépendance tierce
- iOS 17+ (tu peux utiliser `.symbolEffect`, `.contentTransition`, etc.)
- Dark mode doit fonctionner parfaitement avec les nouveaux Color Sets
- Vérifie `xcodebuild build` après chaque modification majeure
- Lance `xcodebuild test` à la fin — les 5 tests doivent toujours passer

## Critères de validation

- [ ] Splash screen s'affiche au lancement puis disparaît
- [ ] Les couleurs partenaire sont cohérentes partout (plus de .blue/.pink bruts)
- [ ] Les cards ont des ombres et coins arrondis
- [ ] Le BalanceBanner a un gradient coloré avec texte blanc
- [ ] Les ExpenseRow ont des avatars cercle avec initiale
- [ ] Les montants utilisent la typo `.rounded`
- [ ] L'empty state est engageant avec animation
- [ ] Le résumé est visible dans ProjectDetailView
- [ ] Dark mode OK sur tous les écrans
- [ ] BUILD SUCCEEDED + 5/5 tests passent
