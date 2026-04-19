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

PROJECT_NUMBER="$(gh project list --owner "$OWNER" --format json \
  | jq -r --arg TITLE "$PROJECT_TITLE" '.projects[] | select(.title == $TITLE) | .number' \
  | head -n1)"

if [[ -z "${PROJECT_NUMBER:-}" || "$PROJECT_NUMBER" == "null" ]]; then
  echo "Project introuvable: $PROJECT_TITLE" >&2
  echo "Lance d'abord scripts/01_create_duospend_project.sh" >&2
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

label_exists() {
  local name="$1"
  gh label list --repo "$REPO" --limit 200 --json name \
    | jq -e --arg NAME "$name" '.[] | select(.name == $NAME)' >/dev/null 2>&1
}

create_label() {
  local name="$1"
  local color="$2"
  local desc="$3"

  if label_exists "$name"; then
    echo "==> Label déjà présent: $name"
  else
    echo "==> Création label: $name"
    run gh label create "$name" --repo "$REPO" --color "$color" --description "$desc"
  fi
}

issue_url_by_title() {
  local title="$1"
  gh issue list --repo "$REPO" --limit 500 --state all --json title,url \
    | jq -r --arg TITLE "$title" '.[] | select(.title == $TITLE) | .url' \
    | head -n1
}

add_issue_to_project() {
  local issue_url="$1"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] gh project item-add $PROJECT_NUMBER --owner $OWNER --url $issue_url"
  else
    gh project item-add "$PROJECT_NUMBER" --owner "$OWNER" --url "$issue_url" >/dev/null 2>&1 || true
  fi
}

create_issue() {
  local title="$1"
  local labels_csv="$2"
  local body="$3"

  local existing_url
  existing_url="$(issue_url_by_title "$title" || true)"

  if [[ -n "${existing_url:-}" ]]; then
    echo "==> Issue déjà présente: $title"
    add_issue_to_project "$existing_url"
    return 0
  fi

  IFS=',' read -r -a labels <<< "$labels_csv"

  local args=(
    issue create
    --repo "$REPO"
    --title "$title"
    --body-file -
  )

  for label in "${labels[@]}"; do
    args+=(--label "$label")
  done

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run] gh'
    printf ' %q' "${args[@]}"
    printf '\n'
    echo "----- body start -----"
    printf '%s\n' "$body"
    echo "----- body end -----"
    echo "[dry-run] gh project item-add $PROJECT_NUMBER --owner $OWNER --url <ISSUE_URL>"
  else
    echo "==> Création issue: $title"
    local output issue_url
    output="$(printf '%s\n' "$body" | gh "${args[@]}")"
    issue_url="$(printf '%s\n' "$output" | tail -n1 | tr -d '\r')"
    add_issue_to_project "$issue_url"
  fi
}

echo "==> Création des labels"
create_label "release"      "B60205" "Bloquant ou lié à la release v1.0"
create_label "post-launch"  "1D76DB" "Travail immédiat après lancement"
create_label "v1.1"         "0E8A16" "Roadmap v1.1"
create_label "v1.2"         "5319E7" "Roadmap v1.2"
create_label "v2"           "A371F7" "Roadmap v2.0"
create_label "codex"        "FBCA04" "Tâche adaptée à Codex"
create_label "needs-human"  "D93F0B" "Action humaine requise"
create_label "docs"         "0075CA" "Documentation"
create_label "app-store"    "C2E0C6" "App Store, metadata, screenshots, soumission"
create_label "analytics"    "0052CC" "Métriques et instrumentation"
create_label "retention"    "C5DEF5" "Rétention, notifications, engagement"
create_label "sync"         "BFD4F2" "iCloud, CloudKit, partage"
create_label "widget"       "F9D0C4" "Widgets"

echo "==> Création des issues"
create_issue "App Store screenshots FR/EN" "release,app-store,codex" $'## Contexte\nProduire les screenshots simulateur FR et EN pour la soumission App Store.\n\n## À faire\n- Captures 6.7" et 5.5"\n- FR + EN\n- Vérifier données crédibles et cohérence visuelle'
create_issue "App Store metadata FR/EN" "release,app-store,codex,docs" $'## Contexte\nFinaliser les métadonnées App Store FR et EN.\n\n## À faire\n- Nom\n- Sous-titre\n- Keywords\n- Description\n- Notes de version'
create_issue "Verify PrivacyInfo.xcprivacy" "release,app-store,codex" $'## Contexte\nVérifier que PrivacyInfo.xcprivacy est complet et cohérent avec l’app local-first.'
create_issue "Set version 1.0.0 build 1" "release,codex" $'## Contexte\nPréparer la release v1.0.\n\n## À faire\n- Vérifier version marketing 1.0.0\n- Vérifier build number 1'
create_issue "Archive Release and upload build" "release,needs-human" $'## Contexte\nProduire une archive Release et uploader le build.\n\n## Note\nAction humaine requise.'
create_issue "Run TestFlight beta" "release,needs-human" $'## Contexte\nLancer une beta TestFlight sur build stable.\n\n## Note\nAction humaine requise.'
create_issue "Submit v1.0 to App Store" "release,needs-human,app-store" $'## Contexte\nSoumettre la première version publique.\n\n## Note\nAction humaine requise.'

create_issue "Add privacy-first analytics" "post-launch,analytics,codex" $'## Contexte\nAjouter une mesure minimale privacy-first.\n\n## Événements minimum\n- app_launched\n- project_created\n- expense_added\n- paywall_shown\n- purchase_completed\n- second_project_created'
create_issue "Create docs/METRICS.md" "post-launch,analytics,docs,codex" $'## Contexte\nCréer le document de pilotage des métriques post-launch.'
create_issue "Prepare user feedback questionnaire" "post-launch,docs,codex" $'## Contexte\nPréparer un questionnaire court pour les premiers utilisateurs.'
create_issue "Add contextual in-app review prompt" "post-launch,retention,codex" $'## Contexte\nDéclencher la demande d’avis au bon moment d’usage.'
create_issue "Add 80 percent budget notification" "post-launch,retention,codex" $'## Contexte\nAjouter une notification quand le budget atteint 80%.'
create_issue "Add project archiving" "post-launch,retention,codex" $'## Contexte\nArchiver un projet terminé et proposer la création d’un nouveau projet.'
create_issue "Launch first ASO iteration" "post-launch,codex,app-store" $'## Contexte\nPremière itération ASO post-launch.'

create_issue "Implement iCloud sync same Apple ID" "v1.1,sync,codex" $'## Contexte\nActiver la sync iCloud pour le même compte Apple.'
create_issue "Add project templates" "v1.1,codex" $'## Contexte\nAjouter des templates de projets.'
create_issue "Add expense search" "v1.1,codex" $'## Contexte\nAjouter la recherche dans les dépenses.'
create_issue "Add expense categories" "v1.2,codex" $'## Contexte\nAjouter des catégories de dépenses avec SF Symbols.'
create_issue "Add charts and breakdowns" "v1.2,codex" $'## Contexte\nAjouter des graphiques de répartition et de suivi.'
create_issue "Implement CloudKit Sharing for two Apple IDs" "v2,sync,codex" $'## Contexte\nPartager un projet entre deux comptes Apple distincts avec CloudKit Sharing.'

echo
echo "==> Terminé"
echo "Project: $PROJECT_TITLE (#$PROJECT_NUMBER)"
echo "Repo:    $REPO"
