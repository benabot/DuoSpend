#!/usr/bin/env bash
set -euo pipefail

EXPECTED_ROOT="/Users/benoitabot/Sites/DuoSpend"
OWNER="benabot"
REPO="benabot/DuoSpend"
PROJECT_TITLE="DuoSpend"
DRY_RUN=0

usage() {
  cat <<USAGE
Usage:
  $0 [--owner <owner>] [--repo <owner/repo>] [--title <title>] [--dry-run]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
    --repo) REPO="$2"; shift 2 ;;
    --title) PROJECT_TITLE="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Argument inconnu: $1" >&2; exit 1 ;;
  esac
done

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "Commande manquante: $1" >&2; exit 1; }
}

require_cmd gh
require_cmd jq
require_cmd git
require_cmd curl

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ "$ROOT" != "$EXPECTED_ROOT" ]]; then
  echo "Erreur: lance ce script depuis $EXPECTED_ROOT" >&2
  echo "Repo courant: ${ROOT:-<hors repo>}" >&2
  exit 1
fi

gh auth status >/dev/null

SCOPES="$(curl -sI -H "Authorization: Bearer $(gh auth token)" https://api.github.com/user \
  | tr -d '\r' | awk -F': ' '/^x-oauth-scopes:/ {print $2}')"

if [[ "$SCOPES" != *project* ]]; then
  echo "Le token GitHub actif n'a pas le scope 'project'." >&2
  echo "Lance: gh auth refresh --scopes project" >&2
  exit 1
fi

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] '
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

get_project_number() {
  gh project list --owner "$OWNER" --format json \
    | jq -r --arg TITLE "$PROJECT_TITLE" '.projects[] | select(.title == $TITLE) | .number' \
    | head -n1
}

field_exists() {
  local project_number="$1"
  local field_name="$2"
  gh project field-list "$project_number" --owner "$OWNER" --format json \
    | jq -e --arg NAME "$field_name" '.fields[] | select(.name == $NAME)' >/dev/null 2>&1
}

create_single_select_field() {
  local project_number="$1"
  local name="$2"
  local options_csv="$3"

  if field_exists "$project_number" "$name"; then
    echo "==> Champ déjà présent: $name"
  else
    echo "==> Création champ: $name"
    run gh project field-create "$project_number" --owner "$OWNER" --name "$name" --data-type "SINGLE_SELECT" --single-select-options "$options_csv"
  fi
}

echo "==> Vérification accès repo GitHub: $REPO"
gh repo view "$REPO" >/dev/null

PROJECT_NUMBER="$(get_project_number || true)"

if [[ -z "${PROJECT_NUMBER:-}" || "$PROJECT_NUMBER" == "null" ]]; then
  echo "==> Création du Project: $PROJECT_TITLE"
  run gh project create --owner "$OWNER" --title "$PROJECT_TITLE"
  if [[ "$DRY_RUN" -eq 0 ]]; then
    sleep 2
    PROJECT_NUMBER="$(get_project_number)"
  else
    PROJECT_NUMBER="<PROJECT_NUMBER>"
  fi
else
  echo "==> Project déjà présent: #$PROJECT_NUMBER"
fi

echo "==> Project number: $PROJECT_NUMBER"

echo "==> Liaison du Project au repo $REPO"
run gh project link "$PROJECT_NUMBER" --owner "$OWNER" --repo "$REPO"

if [[ "$DRY_RUN" -eq 0 ]]; then
  create_single_select_field "$PROJECT_NUMBER" "Priority" "P0,P1,P2,P3"
  create_single_select_field "$PROJECT_NUMBER" "Track" "Release,Post-launch,V2,Icebox"
  create_single_select_field "$PROJECT_NUMBER" "Version" "v1.0,v1.1,v1.2,v2.0,Later"
  create_single_select_field "$PROJECT_NUMBER" "Effort" "XS,S,M,L"
  create_single_select_field "$PROJECT_NUMBER" "Area" "App Store,Core App,UX,Monetization,Analytics,Retention,Sync,Widgets,Docs"
else
  echo "==> Champs à créer:"
  echo " - Priority"
  echo " - Track"
  echo " - Version"
  echo " - Effort"
  echo " - Area"
fi

echo
echo "==> Terminé"
echo "Project: $PROJECT_TITLE"
echo "Repo:    $REPO"
echo
echo "Dans l'UI GitHub Project, active ensuite:"
echo "Workflows -> Auto-add items"
echo "Filtre: repo:$REPO is:issue is:open"
