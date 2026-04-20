# .codex — configuration locale DuoSpend

Ce dossier contient les agents et skills **spécifiques au projet**.

## Règle simple

- `agents/` = spécialisations orientées tâche
- `skills/` = connaissances et garde-fous réutilisables dans ce repo

## Ordre d'autorité

1. `CLAUDE.md`
2. `AGENTS.md`
3. fichiers de `agents/`
4. fichiers de `skills/`

## Usage recommandé

- Toute tâche SwiftUI/SwiftData DuoSpend doit préférer ces fichiers locaux.
- Les skills globales restent utiles pour Git, shell, rédaction ou automatisation générique.
