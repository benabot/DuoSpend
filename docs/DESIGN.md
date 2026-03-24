# DESIGN.md — DuoSpend

Ce document regroupe les règles visuelles stables du produit.
Il sert de référence UI. Il ne doit pas contenir de logique métier ni de détails de release App Store.

## 1. Intention produit

L’interface doit faire ressortir trois choses :
- la simplicité ;
- la lisibilité des montants ;
- la compréhension immédiate du solde entre deux partenaires.

Priorités visuelles :
1. comprendre le statut financier d’un projet ;
2. lire rapidement les dépenses ;
3. agir sans friction.

## 2. Principes UI

- Clair avant d’être décoratif.
- Les montants et balances priment sur l’habillage.
- Peu d’éléments par écran.
- Hiérarchie visuelle nette.
- Les animations doivent confirmer une action, jamais distraire.
- Les composants doivent rester cohérents entre tous les écrans.

## 3. Couleurs

### Tokens de référence

| Token | Usage |
|---|---|
| `accentPrimary` | CTA, accent principal |
| `partner1` | Couleur d’identité partenaire 1 |
| `partner2` | Couleur d’identité partenaire 2 |
| `cardBackground` | Fond de carte |
| `successGreen` | État équilibré / positif |

### Règles d’usage
- `accentPrimary` pour l’action principale et certains accents de navigation.
- `partner1` et `partner2` uniquement pour identifier les personnes ou leurs contributions.
- `successGreen` uniquement pour un état positif confirmé.
- Ne pas multiplier les couleurs sémantiques sans nécessité.
- Conserver un contraste lisible en light et dark mode.

## 4. Typographie

### Hiérarchie
- Montants majeurs : style fort et très lisible.
- Titres de section : hiérarchie intermédiaire.
- Texte courant : sobre.
- Texte secondaire : discret mais lisible.

### Règles
- Les montants importants utilisent un rendu arrondi cohérent avec l’identité produit.
- Les tailles doivent être stables d’un écran à l’autre.
- Les labels secondaires ne doivent jamais concurrencer les montants.
- Préférer la sobriété à la densité.

## 5. Espacement et structure

- Utiliser des cartes pour grouper les informations d’un projet.
- Aérer les listes pour éviter l’effet tableur.
- Garder des marges stables entre sections.
- Les CTA importants doivent rester faciles à atteindre sur iPhone.
- Les modales et sheets doivent respirer.

## 6. Animations

### Objectif
Renforcer la perception de fluidité et de qualité sans ralentir la lecture.

### Règles
- Animation courte et utile.
- Même famille d’animation pour les interactions similaires.
- Les changements de montant peuvent être animés avec sobriété.
- Les transitions d’entrée doivent rester rares.
- Toute animation doit rester compatible avec une lecture rapide.

## 7. Composants clés

## 7.1 ProjectCard
Rôle : résumé principal d’un projet.

Doit montrer :
- identité du projet ;
- progression budget si disponible ;
- balance ou statut financier ;
- accès rapide au détail.

Contraintes :
- l’emoji ne doit pas voler l’attention au montant ;
- la balance doit être immédiatement lisible ;
- la carte doit rester claire en dark mode.

## 7.2 BalanceBanner
Rôle : rendre visible la réponse à la question centrale.

Doit montrer :
- qui doit à qui ;
- ou l’état équilibré ;
- sans ambiguïté de formulation.

Contraintes :
- message très lisible ;
- contraste fort ;
- aucun élément secondaire ne doit gêner la lecture.

## 7.3 ExpenseRow
Rôle : lecture rapide d’une dépense.

Doit montrer :
- titre ;
- montant ;
- payeur ;
- date ou information secondaire utile.

Contraintes :
- le montant reste l’ancre visuelle principale ;
- l’identité du payeur doit être reconnaissable vite ;
- éviter toute surcharge visuelle.

## 7.4 Empty states
Rôle : guider sans frustrer.

Doivent :
- expliquer l’absence de contenu ;
- proposer une action claire ;
- rester cohérents avec le ton simple de l’app.

## 8. Icônes et imagerie

- Préférer SF Symbols quand possible.
- Limiter les illustrations décoratives.
- Les icônes servent la compréhension, pas l’effet.
- L’emoji projet est acceptable comme repère rapide, pas comme élément dominant.

## 9. Accessibilité

- Contraste suffisant en light et dark mode.
- Taille de texte raisonnablement robuste.
- Libellés clairs pour les actions.
- Les couleurs partenaires ne doivent pas être l’unique signal.
- Les montants et statuts doivent rester compréhensibles sans code couleur seul.

## 10. Cohérence d’ensemble

Avant toute nouvelle UI, vérifier :
- est-ce qu’on comprend mieux le solde ?
- est-ce que l’écran est plus simple qu’avant ?
- est-ce que le composant réutilise le langage visuel existant ?
- est-ce que l’animation apporte quelque chose ?

## 11. Ce qui ne doit pas vivre ici

Ne pas remettre ici :
- règles Swift / SwiftUI ;
- détails d’architecture ;
- checklist TestFlight / App Store ;
- stratégie ASO ;
- roadmap monétisation.
