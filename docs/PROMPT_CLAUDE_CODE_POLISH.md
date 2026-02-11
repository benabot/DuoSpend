# Prompt Claude Code — Polish final + bugs UX

> Copie-colle ce prompt dans Claude Code depuis `~/Sites/DuoSpend`

---

## Contexte

Lis `CLAUDE.md` pour les conventions. L'app compile, les tests passent, le design a été amélioré. Il reste des bugs UX et du polish à faire pour que l'app soit prête à utiliser.

---

## Bugs à corriger

### 1. Bouton retour manquant

Quand on tape sur une ProjectCard pour naviguer vers ProjectDetailView, il n'y a **pas de bouton retour** `< DuoSpend` en haut à gauche. L'utilisateur est bloqué dans le détail.

Diagnostic probable : le `NavigationLink(value:)` dans la List ne génère pas la navigation standard. Vérifie :
- Qu'il n'y a qu'un seul `NavigationStack` (dans `ProjectListView`, pas dans `ProjectDetailView`)
- Que `ProjectDetailView` n'est pas wrappé dans un `NavigationStack` supplémentaire
- Que `.navigationDestination(for: Project.self)` est bien attaché à la `List` ou au `NavigationStack`
- Teste dans le simulateur que le swipe-back et le bouton retour fonctionnent

### 2. CreateProjectView — Simplifier le formulaire

Le formulaire actuel a 4 sections (Projet, Emoji, Partenaires, Budget). C'est trop. Simplifie :

- **Fusionne "Projet" et "Emoji"** en une seule section. Le nom du projet en premier, puis la grille d'emojis juste en dessous sans titre de section séparé. Ça doit ressembler à un seul bloc cohérent.
- **Budget OBLIGATOIRE** : le budget n'est plus optionnel. C'est le cœur du concept (budget par projet). 
  - Renomme la section "Budget (optionnel)" en "Budget du projet"
  - Le placeholder : "Ex : 5 000 €"
  - Le bouton "Créer" est désactivé tant que le budget est vide ou ≤ 0
  - Supprime le footer et le mot "optionnel" partout
  - Dans le modèle `Project.swift`, change `var budget: Decimal?` en `var budget: Decimal` (non optionnel)
  - Mets à jour `EditProjectView` en conséquence
  - Mets à jour `SampleData.swift` si nécessaire
  - Dans `ProjectDetailView`, supprime le `if let budget` et affiche toujours la barre de progression budget
  - Dans `ProjectCard`, affiche toujours la mini barre de progression budget

Résultat : 3 sections max (Projet + emoji, Partenaires, Budget).

### 3. Animation sélection emoji

Quand on tape un emoji dans la grille, ajoute une animation `.spring(response: 0.3, dampingFraction: 0.5)` avec un `scaleEffect` qui fait un petit rebond (1.0 → 1.3 → 1.0). C'est un micro-détail qui rend l'interaction vivante.

---

## Améliorations visuelles

### 4. ProjectCard — Supprimer le chevron NavigationLink

Le `NavigationLink` ajoute un chevron `>` gris à droite de la card. C'est redondant puisque la card entière est cliquable. Utilise ce pattern pour le masquer :

```swift
NavigationLink(value: project) {
    ProjectCard(project: project)
}
.buttonStyle(.plain) // Supprime le style par défaut du NavigationLink
```

Ou bien utilise un `ZStack` avec un `NavigationLink` invisible si `.buttonStyle(.plain)` ne cache pas le chevron.

### 5. ProjectDetailView — Fond chaud

Applique le même fond `.warmBackground` que la `ProjectListView` :
```swift
.scrollContentBackground(.hidden)
.background(Color.warmBackground)
```

### 6. AddExpenseView — Rendre plus clair

- Section "Payé par" : afficher les noms des partenaires avec leur couleur (partner1 en bleu, partner2 en rose) dans le Picker segmenté
- Section "Répartition" : quand "Custom" est sélectionné, afficher un Slider de 0 à 100 au lieu d'un TextField numérique. Afficher "Marie: 70% / Thomas: 30%" dynamiquement sous le slider.
- Placeholder du titre : "Restaurant, hôtel, courses…"

### 7. SplashScreen — Plus punchy

Le splash actuel est fonctionnel mais basique. Améliore-le :
- L'emoji 💕 apparaît en premier (scale de 0 → 1 avec bounce), puis le texte "DuoSpend" glisse depuis le bas avec un fade-in
- Fond : léger gradient vertical de `.accentPrimary.opacity(0.05)` vers blanc
- Durée totale : 1.8s (pas 2s, c'est un poil trop long)

### 8. ProjectDetailView — Header plus compact

Le BalanceBanner prend beaucoup de place. S'il n'y a aucune dépense, affiche un message encourageant à la place du banner :
- "Ajoutez votre première dépense 🎉" en `.title3` centré, couleur `.accentPrimary`
- Le BalanceBanner n'apparaît que quand il y a au moins 1 dépense

### 9. Swipe to delete — Style

Quand on swipe une dépense pour la supprimer, utilise le label `.destructive` standard iOS avec l'icône trash :
```swift
.swipeActions(edge: .trailing) {
    Button(role: .destructive) {
        modelContext.delete(expense)
    } label: {
        Label("Supprimer", systemImage: "trash")
    }
}
```

Vérifie que c'est bien implémenté avec cette syntaxe (pas juste `.onDelete`).

---

## Tests finaux

Après toutes les modifications :

1. `xcodebuild build` — doit passer
2. `xcodebuild test` — 5/5 tests doivent passer
3. Vérifie dans le simulateur :
   - Splash screen → empty state → créer projet → la card apparaît
   - Tap sur la card → ProjectDetailView **avec bouton retour**
   - Ajouter une dépense → le banner apparaît avec gradient
   - Bouton retour → retour à la liste
   - Swipe to delete fonctionne
   - Dark mode (Cmd+Shift+A) → tout reste lisible

---

## Contraintes

- Zéro dépendance tierce
- iOS 17+
- Respecter `CLAUDE.md`
- Dark mode parfait
