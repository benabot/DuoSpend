---
name: duospend-architecture
description: Référence locale sur l'architecture DuoSpend pour SwiftUI, MVVM, Observation, SwiftData et les responsabilités des couches.
---

# Skill — Architecture DuoSpend

## Objectif

Éviter les dérives d'architecture et maintenir une séparation nette entre Views, ViewModels, Services et Models.

## Architecture cible

```text
SwiftUI Views
    ↓
ViewModels @Observable
    ↓
Services métier purs
    ↓
SwiftData (@Model, ModelContext)
```

## Règles fixes

- Les vues affichent et déclenchent des actions.
- Les ViewModels orchestrent l'état d'écran et le CRUD.
- Les Services portent la logique métier pure.
- Les Models représentent les données persistées.
- Le calcul de balance appartient à `Services/BalanceCalculator.swift`.

## Anti-patterns

- calcul métier dans une vue SwiftUI ;
- mutation SwiftData cachée dans un composant ;
- duplication du calcul de balance dans plusieurs fichiers ;
- helper “utilitaire” fourre-tout pour contourner la structure.
