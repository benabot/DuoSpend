# DuoSpend — Architecture

## Objectif

Documenter l’architecture technique **stable** du projet.
Ce document décrit la structure logique du code, les responsabilités par couche et les invariants techniques. Il ne doit pas servir de backlog, de journal de release ou de checklist App Store.

---

## Vue d’ensemble

```text
SwiftUI Views
    ↓  (@Query, interactions)
ViewModels @Observable
    ↓  (CRUD, orchestration, états d’UI)
Services métier purs
    ↓
SwiftData (@Model, ModelContext)
    ↓
Persistance locale
```

### Principes techniques

- App iOS SwiftUI, iPhone uniquement pour le MVP.
- Architecture MVVM avec Observation framework.
- Persistance principale : SwiftData.
- Local-first : l’app doit rester utilisable sans réseau.
- Frameworks Apple uniquement.
- La logique métier reste dans `Services/` et `ViewModels/`.
- Les vues affichent, déclenchent des actions et lisent les données simples ; elles ne portent pas le calcul métier.

---

## Organisation logique du projet

```text
DuoSpend/
├── App/            # point d’entrée, configuration de l’app et du ModelContainer
├── Models/         # entités SwiftData et types métier simples
├── Views/          # écrans SwiftUI
├── Views/Components/
├── ViewModels/     # orchestration par écran
├── Services/       # logique métier pure et testable
├── Extensions/     # helpers ciblés
└── Resources/      # assets, AppIcon, PrivacyInfo.xcprivacy
```

### Responsabilités par dossier

#### `App/`
- Déclare l’entrée de l’application.
- Configure le `ModelContainer`.
- Ne contient pas de logique métier.

#### `Models/`
- Déclare les entités persistées et les types liés.
- Peut contenir des propriétés calculées simples.
- Ne contient pas de logique de calcul métier transverse.

#### `Views/`
- Affichage SwiftUI.
- Lecture des collections simples via `@Query`.
- Déclenchement des actions utilisateur.
- Aucune règle métier complexe.

#### `ViewModels/`
- Gestion des états d’écran.
- Validation locale des formulaires.
- Orchestration CRUD via `ModelContext`.
- Appels aux services métier.

#### `Services/`
- Logique métier pure, testable unitairement.
- Pas de dépendance SwiftUI.
- Pas de dépendance directe à la vue.

#### `Extensions/`
- Helpers ciblés et non centraux.
- Pas de logique produit critique cachée dans des extensions “utilitaires” génériques.

---

## Flux de données

### Lecture
- Les vues lisent les collections simples via `@Query`.
- Les vues passent les données nécessaires aux composants.
- Les vues peuvent utiliser `@Bindable` pour les bindings UI.

### Mutation
- Les opérations CRUD passent par `ModelContext`.
- Les actions complexes transitent par le ViewModel de l’écran concerné.
- Les services métier calculent et retournent un résultat ; ils ne modifient pas directement l’interface.

### Règle centrale
- **Les vues ne calculent jamais la balance métier.**
- Le calcul du solde appartient à un service dédié.

---

## Modèle de données

## `Project`
Racine fonctionnelle d’un budget commun entre deux partenaires.

Responsabilités :
- stocker les métadonnées du projet ;
- porter les noms des deux partenaires ;
- regrouper les dépenses ;
- exposer le budget cible.

Invariants :
- exactement deux partenaires ;
- budget exprimé en `Decimal` ;
- relation explicite vers les dépenses ;
- suppression en cascade documentée si conservée.

> Note d’alignement : le journal de décisions indique que le budget doit être **obligatoire**. Si le code utilise encore `Decimal?`, il faut considérer cela comme une dette de cohérence à corriger.

## `Expense`
Dépense rattachée à un projet.

Responsabilités :
- stocker le titre ;
- stocker le montant ;
- stocker le payeur ;
- stocker la règle de répartition ;
- stocker la date ;
- référencer son projet.

Invariants :
- une dépense appartient à un projet ;
- montant en `Decimal`, jamais `Double` ;
- aucun calcul métier complexe dans le modèle.

## `PartnerRole`
Type métier représentant le partenaire payeur ou concerné par la répartition.

## `SplitRatio`
Type métier représentant une répartition :
- égalitaire ;
- personnalisée.

---

## Services métier

## `BalanceCalculator`
Service central de calcul du solde.

Entrée :
- une liste de dépenses d’un projet.

Sortie :
- total dépensé ;
- part théorique de chaque partenaire ;
- solde net ;
- statut lisible du type “A doit X à B” ou “équilibre”.

Contraintes :
- calcul purement déterministe ;
- aucun accès direct à SwiftUI ;
- aucun accès direct à la navigation ;
- testable indépendamment du stockage.

### Évolutions futures possibles
À créer seulement si le besoin devient réel :
- service de fusion/synchronisation ;
- service de formatage métier ;
- service d’export.

---

## Persistance et synchronisation

### Persistance
- SwiftData est la persistance principale.
- Les entités persistées utilisent `@Model`.
- Les relations doivent être explicites.
- Les mutations passent par `ModelContext`.

### Synchronisation
- La cible v1 reste **local-first**.
- Une synchronisation iCloud / CloudKit peut être activée comme évolution contrôlée.
- La synchronisation ne doit jamais devenir une dépendance dure du fonctionnement métier.

---

## Gestion des montants et devise

- Tous les montants métier sont en `Decimal`.
- `Double` est interdit pour les montants fonctionnels.
- L’affichage utilise un format monétaire cohérent.
- Le MVP peut rester centré sur l’euro tant qu’aucune stratégie multi-devises n’est actée.

---

## Observabilité et erreurs

### Observabilité
- `Logger` au lieu de `print()`.
- Les logs servent au diagnostic, pas à la logique produit.

### Erreurs
- Types d’erreurs explicites (`LocalizedError` ou équivalent).
- Messages compréhensibles côté UI.
- Pas de `!` hors contexte de preview/test très contrôlé.

---

## Règles de découpage

- Sous-vue > 40 lignes : extraction.
- Vue > 150 lignes : refactorisation.
- Un composant réutilisable garde une responsabilité unique.
- Un ViewModel n’existe que si l’écran a une vraie orchestration à porter.

---

## Ce qui n’appartient pas à ce document

Ne pas remettre ici :
- backlog produit ;
- étapes de release ;
- prompts Claude ;
- ASO ;
- checklist App Store ;
- commandes shell longues.
