#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Bash helper uninstaller
# ============================================================
#
# Purpose:
#   Remove the managed bash helper block and generated helper file that
#   were installed by bash/install.sh.
#
# Notes:
#   This is a safe, explicit uninstall for the repo's managed bash helper
#   installation pattern. It does not touch unrelated shell config.
# ============================================================

DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=true
fi

SHELL_NAME="${SHELL:-}"
MARKER_BEGIN="# >>> scripts/bash helpers >>>"
MARKER_END="# <<< scripts/bash helpers <<<"
LEGACY_LINE="# Added by scripts/bash/install.sh"

if [[ "$SHELL_NAME" == *"zsh"* ]]; then
  PROFILE_FILE="$HOME/.zshrc"
elif [[ "$SHELL_NAME" == *"bash"* ]]; then
  PROFILE_FILE="$HOME/.bashrc"
else
  PROFILE_FILE="$HOME/.profile"
fi

remove_profile_block() {
  local file="$1"
  local start_marker="$2"
  local end_marker="$3"

  if [[ ! -f "$file" ]]; then
    return
  fi

  awk -v start="$start_marker" -v end="$end_marker" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

remove_legacy_profile_block() {
  local file="$1"
  local legacy="$LEGACY_LINE"

  if [[ ! -f "$file" ]]; then
    return
  fi

  awk -v legacy="$legacy" '
    $0 == legacy { skip = 1; next }
    skip && $0 ~ /^for file in / { next }
    skip && $0 ~ /^  \[ -f / { next }
    skip && $0 ~ /^\[ -f / { next }
    skip && $0 ~ /^done$/ { skip = 0; next }
    skip && $0 ~ /^$/ { next }
    !skip { print }
  ' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

HELPERS_FILE="${SCRIPTS_HELPERS_FILE:-$HOME/.scripts-bash-helpers}"

if [[ "$DRY_RUN" == true ]]; then
  echo "DRY RUN: would remove the managed bash helper block from $PROFILE_FILE"
  if [[ -f "$HELPERS_FILE" ]]; then
    echo "DRY RUN: would delete $HELPERS_FILE"
  fi
  exit 0
fi

if [[ -f "$PROFILE_FILE" ]]; then
  remove_profile_block "$PROFILE_FILE" "$MARKER_BEGIN" "$MARKER_END"
  remove_legacy_profile_block "$PROFILE_FILE"
fi

if [[ -f "$HELPERS_FILE" ]]; then
  rm -f "$HELPERS_FILE"
fi

echo "Removed the managed bash helper block from $PROFILE_FILE"
if [[ -f "$HELPERS_FILE" ]]; then
  echo "Deleted $HELPERS_FILE"
else
  echo "No managed helper file was present at $HELPERS_FILE"
fi
