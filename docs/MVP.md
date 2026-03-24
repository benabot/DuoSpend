# DuoSpend — Spécification MVP

## Vision

DuoSpend aide les couples à gérer leurs dépenses communes **par projet** sans se perdre dans les calculs. L’app répond à une question unique : **« Qui doit combien à qui ? »**

---

## Problème utilisateur

À deux, les dépenses d’un projet commun deviennent vite floues :
- qui a payé quoi ;
- quelle part du budget a déjà été consommée ;
- quel est le solde net entre les deux partenaires.

Le besoin n’est pas de faire de la comptabilité complète. Le besoin est d’obtenir un solde clair, fiable et compréhensible sans calcul mental.

---

## Réponse produit

DuoSpend permet de :
- créer un projet commun pour deux partenaires ;
- définir un budget cible ;
- enregistrer les dépenses du projet ;
- répartir chaque dépense en 50/50 ou en part personnalisée ;
- afficher en permanence qui doit combien à qui.

---

## Personas

### Marie & Thomas — préparation d’un mariage
Ils avancent chacun des frais différents et veulent connaître le solde net à tout moment.

### Léa & Hugo — roadtrip
Ils partagent certaines dépenses mais pas toutes au même ratio ; ils veulent un bilan clair en fin de voyage.

---

## Invariants fonctionnels

- Un projet implique **exactement 2 partenaires**.
- Une dépense appartient à **un seul projet**.
- Tous les montants sont manipulés en `Decimal`.
- Le solde doit rester lisible sans effort.
- Le budget fait partie de la promesse produit et doit être traité comme **obligatoire**.
- L’app doit rester utilisable hors ligne.

---

## Scope MVP

Le MVP couvre :
- création d’un projet ;
- édition et suppression d’un projet ;
- ajout, édition et suppression d’une dépense ;
- calcul du solde entre deux partenaires ;
- budget par projet ;
- consultation hors ligne ;
- persistance locale fiable.

### Position sur la sync
La version 1.0 doit être pensée **local-first**. La synchronisation iCloud / CloudKit peut exister comme évolution contrôlée, mais elle ne fait pas partie du cœur à valider pour le lancement.

---

## Parcours utilisateur

### Première ouverture
1. Écran vide.
2. Création du premier projet.
3. Arrivée sur le détail du projet.

### Usage courant
1. Ouvrir l’app.
2. Consulter la liste des projets.
3. Ouvrir un projet.
4. Voir le budget, le total dépensé et le solde.
5. Ajouter une dépense.
6. Voir le solde se recalculer immédiatement.

### Fin de projet
1. Consulter le solde final.
2. Régler la dette hors de l’app.
3. Archiver ou supprimer le projet.

---

## Écrans MVP

## 1. `ProjectListView`
Affiche :
- un état vide si aucun projet ;
- sinon une liste de cartes de projet ;
- un accès rapide à la création d’un projet.

Chaque carte montre au minimum :
- emoji + nom du projet ;
- budget et total dépensé ;
- indicateur synthétique de balance.

## 2. `CreateProjectView`
Champs attendus :
- nom du projet ;
- emoji ;
- partenaire 1 ;
- partenaire 2 ;
- budget.

Le budget doit être saisi à la création si l’invariant “budget obligatoire” est conservé comme source de vérité.

## 3. `ProjectDetailView`
Affiche :
- en-tête projet ;
- progression budget / dépensé ;
- bannière de balance ;
- liste des dépenses ;
- action d’ajout de dépense ;
- action d’édition du projet.

## 4. `AddExpenseView`
Champs attendus :
- titre ;
- montant ;
- payé par ;
- répartition ;
- date.

---

## Composants réutilisables

- `ProjectCard`
- `ExpenseRow`
- `BalanceBanner`

Ces composants servent l’interface, mais ne doivent pas embarquer la logique de calcul métier.

---

## Logique métier

## Algorithme de balance

Entrée : liste des dépenses d’un projet.

Principe :
- calculer la part théorique de chacun pour chaque dépense ;
- comparer cette part avec le payeur réel ;
- agréger l’écart pour obtenir une balance nette.

Résultat possible :
- partenaire 1 doit X au partenaire 2 ;
- partenaire 2 doit X au partenaire 1 ;
- équilibre.

### Scénarios de validation minimaux
- cas 50/50 ;
- cas répartition personnalisée ;
- cas équilibre parfait ;
- cas une seule dépense.

---

## Design fonctionnel minimal

- Les montants sont affichés de manière cohérente.
- Le solde final est visible immédiatement.
- Les formulaires restent courts.
- Les couleurs partenaires servent la lecture, pas la décoration.
- Dark mode supporté.

Le design system détaillé vit dans `docs/DESIGN.md`, pas ici.

---

## Hors scope MVP

Sont exclus du MVP 1.0 :
- groupes ;
- catégories avancées ;
- export PDF ;
- widgets ;
- graphiques ;
- recherche ;
- onboarding complexe ;
- multi-devises ;
- partage CloudKit entre deux comptes Apple ;
- sync locale MultipeerConnectivity ;
- logique premium avancée.

---

## Backlog post-MVP

Fonctionnalités à réévaluer après validation du cœur produit :
- templates de projets ;
- export PDF ;
- catégories de dépenses ;
- widgets ;
- graphiques ;
- recherche dans les dépenses ;
- synchronisation entre deux appareils ;
- partage de projet entre deux comptes Apple.
