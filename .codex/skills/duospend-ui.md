---
name: duospend-ui
description: Référence locale pour construire une UI SwiftUI DuoSpend claire, compacte et cohérente avec DESIGN.md.
---

# Skill — UI DuoSpend

## Priorités visuelles

1. Compréhension immédiate du solde.
2. Lisibilité des montants.
3. Rapidité d'action.

## Règles de construction

- Extraire une sous-vue au-delà de 40 lignes.
- Refactoriser une vue au-delà de 150 lignes.
- Utiliser les composants du langage visuel existant.
- Les couleurs partenaires servent l'identification, pas la décoration.
- Les animations doivent confirmer une action, jamais ralentir la lecture.

## Composants à privilégier

- `ProjectCard`
- `BalanceBanner`
- `ExpenseRow`
- empty states simples et actionnables

## Contrôle qualité

- Le montant principal est-il l'ancre visuelle ?
- Le message “qui doit combien à qui” est-il visible sans effort ?
- L'écran est-il plus simple après la modification qu'avant ?
