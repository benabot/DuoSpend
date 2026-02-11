# Prompt Claude Code — Design fun (visuel only, zéro changement mécanique)

> Copie-colle ce prompt dans Claude Code depuis `~/Sites/DuoSpend`

---

## Contexte

Lis `CLAUDE.md`. L'app fonctionne, la navigation est OK, les mécaniques sont finalisées. **Ne touche à AUCUNE logique métier, navigation, création, suppression, calcul.** Tu ne modifies QUE le rendu visuel : couleurs, fonts, spacing, animations, layouts des vues existantes.

---

## 1. SplashScreenView — Plus punchy

L'emoji 💕 est petit et le fond est fade.

- Emoji en `.system(size: 72)` (pas 48)
- Ajouter un cercle décoratif derrière l'emoji : `Circle().fill(Color.accentPrimary.opacity(0.1)).frame(width: 120, height: 120)` avec l'emoji en overlay
- Le cercle scale de 0 → 1 avec `.spring(response: 0.6, dampingFraction: 0.5)` (bounce visible)
- Le texte "DuoSpend" en `.system(size: 42)` (pas 38)
- Sous le titre, ajouter un sous-titre "Gérez vos dépenses à deux 💕" en `.subheadline` `.secondary` avec fade-in retardé de 0.5s
- Fond : gradient plus marqué `Color.accentPrimary.opacity(0.08)` → `.systemBackground`

## 2. ProjectListView — Empty state plus engageant

- L'icône `heart.circle.fill` passe de 64pt à 80pt
- Ajouter un cercle décoratif derrière (comme le splash) : `Circle().fill(Color.accentPrimary.opacity(0.08)).frame(width: 140, height: 140)` avec l'icône en overlay
- Le bouton "C'est parti !" doit avoir un `.shadow(color: Color.accentPrimary.opacity(0.3), radius: 8, y: 4)` pour donner de la profondeur
- Ajouter un léger `.scaleEffect` avec `.spring()` sur le bouton au `onAppear` (1.0 → 1.05 → 1.0 subtil)

## 3. ProjectCard — Plus vivante

La card est correcte mais manque d'énergie.

- L'emoji dans son cercle doit être en `.system(size: 28)` (plus gros dans le cercle de 48pt)
- Le cercle emoji : passer de `Color.accentPrimary.opacity(0.12)` à `Color.accentPrimary.opacity(0.15)` et ajouter un léger stroke : `.overlay(Circle().strokeBorder(Color.accentPrimary.opacity(0.2), lineWidth: 1))`
- Le nom du projet en `.system(.headline, design: .rounded).weight(.bold)` (ajouter `.bold`)
- L'ombre de la card : passer de `.black.opacity(0.06)` à `.accentPrimary.opacity(0.08)` pour une ombre colorée subtile au lieu de grise
- Quand la card apparaît dans la liste, ajouter `.transition(.scale(scale: 0.95).combined(with: .opacity))` et `.animation(.spring(response: 0.4, dampingFraction: 0.8), value: project.id)` 

## 4. BalanceBanner — Plus impactant

Le banner est bien mais peut être plus hero :

- Montant en `.system(size: 48)` au lieu de 42
- Ajouter un SF Symbol contextuel au-dessus du montant :
  - Si balanced : `checkmark.circle.fill` en `.successGreen`
  - Si dette : `arrow.left.arrow.right.circle.fill` en `.white.opacity(0.8)`
  - En `.system(size: 28)` avec léger bounce au `onAppear`
- Les noms des partenaires dans le HStack : les mettre en `.callout.weight(.semibold)` (un peu plus gros que `.subheadline`)
- Ajouter un léger `.shadow(color: .black.opacity(0.15), radius: 8, y: 4)` sur tout le banner pour le décoller du fond
- Le padding vertical passe de 24 à 28

## 5. ProjectDetailView — Budget section plus visuelle

La section budget est un simple texte + barre. Rends-la plus visuelle :

- Remplace le layout par un HStack : à gauche le texte "Dépensé" + montant en `.partner1` couleur, à droite "Budget" + montant en `.secondary`
- La `ProgressView` : remplace par une barre custom `GeometryReader` avec `RoundedRectangle(cornerRadius: 6)` :
  - Fond : `Color.accentPrimary.opacity(0.12)`
  - Remplissage : `Color.accentPrimary` animé avec `.animation(.spring, value: balance.totalSpent)`
  - Hauteur : 10pt (au lieu de la barre fine par défaut)
  - Si dépensé > budget : la barre de remplissage devient `.red` 
- Sous la barre, afficher le pourcentage : "42% utilisé" en `.caption` `.secondary` design `.rounded`
- Le empty state "Ajoutez votre première dépense" (retirer le 🎉) : ajouter un SF Symbol `cart.badge.plus` en 44pt au-dessus du texte, couleur `.accentPrimary.opacity(0.6)`, avec `.symbolEffect(.pulse)`

## 6. ExpenseRow — Micro-polish

- L'avatar 40pt : ajouter une légère ombre `.shadow(color: payerColor.opacity(0.3), radius: 3, y: 2)` pour le décoller
- Le titre de la dépense en `.body.weight(.medium)` (ajouter le weight)
- La pastille split (50/50 etc.) : si c'est 50/50, la masquer (c'est le défaut, pas besoin de l'afficher). N'afficher que quand c'est custom.

## 7. AddExpenseView — Touches de couleur

Le formulaire d'ajout est fonctionnel mais gris. Ajouter des touches :

- Le titre de navigation reste "Nouvelle dépense" (pas d'emoji)
- Les boutons "Payé par" : quand sélectionné, la couleur de fond passe de `.opacity(0.15)` à `.opacity(0.2)` et ajouter un `.scaleEffect(isSelected ? 1.03 : 1.0)` avec `.animation(.spring(response: 0.3))`
- Le slider custom : la couleur du track est un gradient `LinearGradient(colors: [.partner1, .partner2], startPoint: .leading, endPoint: .trailing)` au lieu d'une couleur unie

## 8. CreateProjectView & EditProjectView — Touches de couleur

- Titre de navigation : garder "Nouveau projet" et "Modifier le projet" (pas d'emoji)
- Le bouton "Créer" / "Enregistrer" : couleur `.accentPrimary` au lieu de la couleur par défaut
- Les labels de section ("Projet", "Partenaires", "Budget du projet") en `.accentPrimary` :
  ```swift
  Section {
      // fields...
  } header: {
      Text("Projet").foregroundStyle(Color.accentPrimary)
  }
  ```

## 9. Couleurs — Ajustement global

Vérifier / mettre à jour les colorsets dans `Assets.xcassets` :

- `AccentPrimary` : garder #6C5CE7 (violet)
- `Partner1Color` : passer à #0984E3 (bleu vif) si pas déjà
- `Partner2Color` : passer à #E84393 (rose vif) si pas déjà  
- `SuccessGreen` : passer à #00B894 (teal/vert menthe) si pas déjà
- `CardBackground` : light = blanc pur #FFFFFF, dark = #1C1C1E

## 10. Typographie cohérente

Partout où un montant en euros est affiché (cards, banner, rows, detail), s'assurer qu'il utilise `.system(.xxx, design: .rounded)`. Vérifier aussi que les titres de projet utilisent `.rounded`. La typo rounded donne un côté amical et moderne à l'app.

---

## Contraintes absolues

- **NE TOUCHE À AUCUNE MÉCANIQUE** : pas de changement dans la logique de création, navigation, calcul, suppression, sauvegarde
- Zéro dépendance tierce
- iOS 17+
- Dark mode parfait (teste avec Cmd+Shift+A dans le simulateur)
- `xcodebuild build` doit passer
- Les 5 tests existants doivent passer
- Commit à la fin : `git add -A && git commit -m "Design: interface fun et colorée"`
