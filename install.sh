#!/usr/bin/env bash

# ============================================================
# Root installer prompt
# ============================================================
#
# Purpose:
#   Provide a simple interactive entrypoint that asks whether to run
#   bash helper installation and tool installation.
#
# Notes:
#   Delegates to .bash/install.sh and .tools/install.sh to preserve
#   existing install behavior.
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

confirm() {
  local prompt="$1"
  local default="${2:-y}"
  local answer

  if [[ ! -t 0 ]]; then
    [[ "$default" == "y" ]]
    return
  fi

  if [[ "$default" == "y" ]]; then
    read -r -p "$prompt [Y/n]: " answer
    answer="${answer:-Y}"
  else
    read -r -p "$prompt [y/N]: " answer
    answer="${answer:-N}"
  fi

  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

pick_tools_target() {
  local target="${1:-default}"
  local input

  if [[ ! -t 0 ]]; then
    printf '%s\n' "$target"
    return
  fi

  echo "Choose tools install target (default/full/dev/services/cloud/python-ai or specific tools):"
  read -r -p "Target [default]: " input
  printf '%s\n' "${input:-$target}"
}

run_bash=false
run_tools=false
tools_target="${1:-default}"

if confirm "Run bash helper install?" "y"; then
  run_bash=true
fi

if confirm "Run tools install?" "y"; then
  run_tools=true
  tools_target="$(pick_tools_target "$tools_target")"
fi

if [[ "$run_bash" == false && "$run_tools" == false ]]; then
  echo "Nothing selected. Exiting."
  exit 0
fi

if [[ "$run_bash" == true ]]; then
  bash "$SCRIPT_DIR/.bash/install.sh"
fi

if [[ "$run_tools" == true ]]; then
  # Split user input into words so multiple targets are supported.
  read -r -a tool_args <<< "$tools_target"
  bash "$SCRIPT_DIR/.tools/install.sh" "${tool_args[@]}"
fi

echo "Root install flow complete."