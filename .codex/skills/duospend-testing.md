---
name: duospend-testing
description: Référence locale pour valider DuoSpend : build, tests, scénarios critiques et critères de fermeture de tâche.
---

# Skill — Testing DuoSpend

## Validation standard

### Build

```bash
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build 2>&1 | grep -E '^.*(error:|BUILD)' | grep -v appintents
```

### Tests

```bash
xcodebuild -scheme DuoSpend \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  test 2>&1 | grep -E 'passed|failed|error'
```

## Scénarios critiques à couvrir

- création de projet ;
- ajout de dépense ;
- calcul de balance ;
- suppression / édition de dépense ;
- gating Free → Pro ;
- restore purchase si StoreKit concerné.

## Critère de fermeture

Une tâche n'est pas terminée si :
- le build n'est pas propre ;
- un test casse ;
- la doc impactée n'est pas ajustée ;
- une hypothèse importante n'est pas signalée.
