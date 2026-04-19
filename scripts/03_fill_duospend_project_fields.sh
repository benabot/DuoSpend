#!/usr/bin/env bash
set -euo pipefail

EXPECTED_ROOT="/Users/benoitabot/Sites/DuoSpend"
OWNER="benabot"
PROJECT_TITLE="DuoSpend"
DRY_RUN=0

usage() {
  cat <<USAGE
Usage:
  $0 [--owner <owner>] [--title <title>] [--dry-run]
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner) OWNER="$2"; shift 2 ;;
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

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ "$ROOT" != "$EXPECTED_ROOT" ]]; then
  echo "Erreur: lance ce script depuis $EXPECTED_ROOT" >&2
  exit 1
fi

PROJECT_JSON="$(gh project list --owner "$OWNER" --format json)"
PROJECT_NUMBER="$(echo "$PROJECT_JSON" | jq -r --arg TITLE "$PROJECT_TITLE" '.projects[] | select(.title == $TITLE) | .number' | head -n1)"
PROJECT_ID="$(echo "$PROJECT_JSON" | jq -r --arg TITLE "$PROJECT_TITLE" '.projects[] | select(.title == $TITLE) | .id' | head -n1)"

if [[ -z "${PROJECT_NUMBER:-}" || "$PROJECT_NUMBER" == "null" ]]; then
  echo "Project introuvable: $PROJECT_TITLE" >&2
  exit 1
fi

FIELDS_JSON="$(gh project field-list "$PROJECT_NUMBER" --owner "$OWNER" --format json)"
ITEMS_JSON="$(gh project item-list "$PROJECT_NUMBER" --owner "$OWNER" --limit 500 --format json)"

get_field_id() {
  local field_name="$1"
  echo "$FIELDS_JSON" | jq -r --arg NAME "$field_name" '.fields[] | select(.name == $NAME) | .id' | head -n1
}

get_option_id() {
  local field_name="$1"
  local option_name="$2"
  echo "$FIELDS_JSON" | jq -r --arg NAME "$field_name" --arg OPTION "$option_name" \
    '.fields[] | select(.name == $NAME) | .options[] | select(.name == $OPTION) | .id' | head -n1
}

get_item_id_by_title() {
  local title="$1"
  echo "$ITEMS_JSON" | jq -r --arg TITLE "$title" '.items[] | select(.content.title? == $TITLE) | .id' | head -n1
}

set_single_select() {
  local item_title="$1"
  local field_name="$2"
  local option_name="$3"

  local item_id field_id option_id
  item_id="$(get_item_id_by_title "$item_title")"
  field_id="$(get_field_id "$field_name")"
  option_id="$(get_option_id "$field_name" "$option_name")"

  if [[ -z "${item_id:-}" || "$item_id" == "null" ]]; then
    echo "Item introuvable: $item_title" >&2
    return 1
  fi
  if [[ -z "${field_id:-}" || "$field_id" == "null" ]]; then
    echo "Champ introuvable: $field_name" >&2
    return 1
  fi
  if [[ -z "${option_id:-}" || "$option_id" == "null" ]]; then
    echo "Option introuvable: $field_name -> $option_name" >&2
    return 1
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "[dry-run] $item_title :: $field_name = $option_name"
  else
    gh project item-edit --id "$item_id" --project-id "$PROJECT_ID" --field-id "$field_id" --single-select-option-id "$option_id" >/dev/null
    echo "==> $item_title :: $field_name = $option_name"
  fi
}

set_item() {
  local title="$1" status="$2" priority="$3" track="$4" version="$5" effort="$6" area="$7"
  set_single_select "$title" "Status"   "$status"
  set_single_select "$title" "Priority" "$priority"
  set_single_select "$title" "Track"    "$track"
  set_single_select "$title" "Version"  "$version"
  set_single_select "$title" "Effort"   "$effort"
  set_single_select "$title" "Area"     "$area"
}

set_item "App Store screenshots FR/EN" "Todo" "P0" "Release" "v1.0" "M" "App Store"
set_item "App Store metadata FR/EN" "Todo" "P0" "Release" "v1.0" "S" "App Store"
set_item "Verify PrivacyInfo.xcprivacy" "Todo" "P0" "Release" "v1.0" "S" "App Store"
set_item "Set version 1.0.0 build 1" "Todo" "P0" "Release" "v1.0" "XS" "Core App"
set_item "Archive Release and upload build" "Todo" "P0" "Release" "v1.0" "M" "App Store"
set_item "Run TestFlight beta" "Todo" "P0" "Release" "v1.0" "M" "App Store"
set_item "Submit v1.0 to App Store" "Todo" "P0" "Release" "v1.0" "S" "App Store"

set_item "Add privacy-first analytics" "Inbox" "P1" "Post-launch" "v1.1" "M" "Analytics"
set_item "Create docs/METRICS.md" "Inbox" "P1" "Post-launch" "v1.1" "S" "Docs"
set_item "Prepare user feedback questionnaire" "Inbox" "P1" "Post-launch" "v1.1" "S" "Docs"
set_item "Add contextual in-app review prompt" "Inbox" "P1" "Post-launch" "v1.1" "S" "Retention"
set_item "Add 80 percent budget notification" "Inbox" "P1" "Post-launch" "v1.1" "S" "Retention"
set_item "Add project archiving" "Inbox" "P1" "Post-launch" "v1.1" "M" "Retention"
set_item "Launch first ASO iteration" "Inbox" "P2" "Post-launch" "v1.1" "S" "App Store"

set_item "Implement iCloud sync same Apple ID" "Inbox" "P1" "V2" "v1.1" "L" "Sync"
set_item "Add project templates" "Inbox" "P1" "V2" "v1.1" "M" "Core App"
set_item "Add expense search" "Inbox" "P2" "V2" "v1.1" "S" "Core App"
set_item "Add expense categories" "Inbox" "P2" "V2" "v1.2" "M" "Core App"
set_item "Add charts and breakdowns" "Inbox" "P2" "V2" "v1.2" "M" "UX"
set_item "Implement CloudKit Sharing for two Apple IDs" "Inbox" "P1" "V2" "v2.0" "L" "Sync"

echo
echo "==> Remplissage terminé"
