# .codex/

Ce dossier contient la configuration locale pour [OpenAI Codex CLI](https://developers.openai.com/codex/).

## Fichiers

- `config.toml` — configuration locale du repo : fichiers d'instructions additionnels, commandes utiles, chemins à ignorer.

## Hiérarchie des instructions Codex

Quand Codex démarre dans ce repo, il lit :

1. `~/.codex/AGENTS.md` — instructions globales utilisateur (si présent)
2. `AGENTS.md` à la racine du repo — instructions projet (**obligatoire**)
3. `CLAUDE.md` à la racine — déclaré en fallback dans `config.toml`
4. `AGENTS.override.md` dans un sous-dossier — priorise sur les précédents (non utilisé ici)

## Pour activer cette config

```bash
# Vérifier que Codex CLI est installé
codex --version

# Depuis la racine du repo
cd /Users/benoitabot/Sites/DuoSpend
codex
```

Codex reprend automatiquement la config du dossier courant.

## Pour réinitialiser

Il suffit de supprimer ce dossier. Codex reprendra ses réglages par défaut.
