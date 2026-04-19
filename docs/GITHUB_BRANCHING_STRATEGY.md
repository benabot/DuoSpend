# GITHUB_BRANCHING_STRATEGY.md — DuoSpend

## Objectif

Définir une stratégie de branches simple, robuste et adaptée à un **développement solo avec Codex**, **sans Pull Requests**.

Le principe est volontairement minimal :
- le **GitHub Project** pilote les tâches ;
- les **Issues** servent de support de travail quand une tâche mérite un cadrage ;
- le code avance sans PR, avec validation locale avant intégration dans la branche stable.

---

## 1. Principes

### Règles générales

- **Pas de PR obligatoires.**
- **Un commit = une tâche atomique** autant que possible.
- **`main` reste stable.**
- **`dev` sert à l’intégration continue du travail courant.**
- Les branches `task/*` sont **optionnelles** et réservées aux chantiers risqués, larges, ou isolables.
- Toute tâche terminée doit être reflétée dans le **GitHub Project** et, si nécessaire, dans `docs/TODO.md`.

### Ce que cette stratégie cherche à éviter

- la lourdeur des PR pour un projet solo ;
- le travail directement sur `main` ;
- les branches longues qui dérivent ;
- un tableau Project déconnecté du code réel.

---

## 2. Rôle des branches

### `main`

Branche stable.

Doit contenir uniquement :
- du code validé ;
- des versions prêtes à être testées sérieusement ou publiées ;
- un historique lisible des jalons importants.

**On n’y développe pas directement.**

### `dev`

Branche de travail principale.

Doit contenir :
- le développement quotidien ;
- les tâches terminées et testées localement ;
- l’intégration progressive avant passage vers `main`.

C’est la branche normale pour Codex et pour le travail courant.

### `task/*`

Branches temporaires, utilisées seulement quand utile.

Exemples :
- `task/123-fix-paywall-copy`
- `task/124-cloudkit-audit`
- `task/125-export-pdf-refactor`

À utiliser quand :
- la tâche touche plusieurs fichiers ;
- le risque de casse est réel ;
- tu veux isoler un chantier avant de l’intégrer dans `dev`.

À éviter pour :
- les micro-fixes ;
- les tâches triviales ;
- les changements de documentation simples.

---

## 3. Flux de travail recommandé

## Cas standard — tâche simple

1. La tâche existe dans le GitHub Project.
2. Si nécessaire, elle a une Issue associée.
3. Le travail se fait sur `dev`.
4. Codex ou le développeur effectue les modifications.
5. Build + tests + vérification fonctionnelle locale.
6. Commit sur `dev`.
7. Mise à jour du statut de la tâche dans le Project : `Done`.

### Exemple

```bash
git checkout dev
git pull origin dev
# travail
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build

git add .
git commit -m "fix: correction du wording du paywall"
git push origin dev
```

---

## Cas prudent — tâche isolée

1. Créer une branche `task/*` depuis `dev`.
2. Travailler dessus.
3. Vérifier localement.
4. Merger localement dans `dev`.
5. Pousser `dev`.
6. Supprimer la branche temporaire.

### Exemple

```bash
git checkout dev
git pull origin dev
git checkout -b task/123-fix-paywall-copy

# travail
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build

git add .
git commit -m "fix: correction du wording du paywall"

git checkout dev
git merge task/123-fix-paywall-copy
git push origin dev
git branch -d task/123-fix-paywall-copy
```

---

## Passage de `dev` vers `main`

Le passage vers `main` doit correspondre à un lot propre :
- fin de sprint ;
- build stable ;
- version TestFlight ;
- release interne ;
- préparation App Store.

### Exemple

```bash
git checkout main
git pull origin main
git merge dev
git push origin main
```

---

## 4. Utilisation avec GitHub Project

Le GitHub Project sert à piloter le travail, pas à remplacer Git.

### Statuts recommandés

- `Inbox`
- `Todo`
- `In Progress`
- `Blocked`
- `Done`

### Interprétation

- **Inbox** : idée ou tâche capturée, pas encore triée.
- **Todo** : prête à être prise.
- **In Progress** : en cours de réalisation.
- **Blocked** : dépendance externe, décision humaine, compte Apple, App Store Connect, etc.
- **Done** : terminé et intégré dans `dev` au minimum.

### Règle simple

Une tâche ne passe en `Done` que si :
- le code est intégré dans `dev`, ou
- la tâche documentaire / organisationnelle est vraiment terminée.

---

## 5. Utilisation avec Codex

Codex ne travaille pas avec un cycle PR. Le flux attendu est le suivant :

### Pour une tâche standard
- Codex lit l’Issue ou la tâche Project.
- Codex modifie le code sur `dev`.
- Codex commit avec un message propre.
- Le développeur valide localement.
- La carte passe à `Done`.

### Pour une tâche sensible
- Codex travaille sur `task/...`.
- Le développeur merge localement vers `dev` après validation.
- La carte passe à `Done`.

### Tâches à garder humaines
Certaines tâches ne doivent pas être déléguées entièrement :
- création du compte Apple Developer ;
- actions App Store Connect ;
- gestion de secrets ;
- réglages de signing ;
- tests finaux sur appareil réel.

Ces tâches doivent être marquées `Blocked` ou clairement annotées comme **humaine requise**.

---

## 6. Nommage des branches

### Branche temporaire

Format recommandé :

```text
task/<numero-issue>-<slug-court>
```

Exemples :
- `task/101-app-store-metadata`
- `task/118-privacyinfo-audit`
- `task/132-project-templates`

Si aucune Issue n’existe :

```text
task/<slug-court>
```

Exemple :
- `task/fix-dark-mode-spacing`

---

## 7. Convention de commits

Préfixes recommandés :
- `feat:`
- `fix:`
- `refactor:`
- `style:`
- `docs:`
- `test:`
- `chore:`

Exemples :
- `fix: suppression du flash onboarding`
- `docs: réorganisation du todo v1 et post-launch`
- `feat: ajout de l'archivage projet`

---

## 8. Règles de validation avant intégration

Avant d’intégrer un changement dans `dev`, vérifier selon le type de tâche :

### Code applicatif
- build OK ;
- tests OK si concernés ;
- pas de régression évidente ;
- pas de debug résiduel non voulu.

### Documentation
- contenu à jour ;
- cohérence avec la roadmap réelle ;
- pas de duplication inutile.

### Release
- versionnement cohérent ;
- infos App Store à jour ;
- cohérence avec `ROADMAP_V2.md`, `TODO.md`, `DECISIONS.md`.

---

## 9. Règle de simplicité

Si une tâche prend moins de 30 minutes et touche peu de surface :
- travail direct sur `dev`.

Si une tâche est incertaine, risquée, ou large :
- branche `task/*`.

Ne pas industrialiser davantage tant que le flux simple suffit.

---

## 10. Résumé opérationnel

### Flux normal
- Project → `Todo`
- travail sur `dev`
- build/test
- commit
- `Done`

### Flux prudent
- Project → `Todo`
- branche `task/*`
- build/test
- merge local dans `dev`
- suppression branche
- `Done`

### Flux release
- `dev` validée
- merge local vers `main`
- tag / release / archive si nécessaire

---

## 11. Ce que cette stratégie exclut volontairement

- Pull Requests obligatoires
- reviews formelles systématiques
- branches longues de plusieurs semaines
- GitFlow complet
- sur-automatisation du workflow

Le projet DuoSpend est un projet solo : la stratégie doit rester **pragmatique**, **lisible**, et **rapide à exécuter**.
