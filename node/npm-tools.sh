#!/usr/bin/env bash

# ============================================================
# Node tool manifest
# ============================================================
#
# Purpose:
#   Review and install the canonical Node tool list used by the
#   repo's shared installer without maintaining a second copy.
#
# Notes:
#   The canonical package list lives in .tools/common.sh. This script
#   reads that list so manual review/install flows cannot drift from
#   the repo's install bundle definitions.
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" && pwd)"
source "$SCRIPT_DIR/../.tools/common.sh"

NODE_PACKAGE_PROFILE="${NODE_PACKAGE_PROFILE:-full}"
if [[ "$NODE_PACKAGE_PROFILE" == "core" ]]; then
  NODE_TOOLS=("${NODE_CORE_PACKAGES[@]}")
else
  NODE_TOOLS=("${NODE_FULL_PACKAGES[@]}")
fi

usage() {
  cat <<'EOF'
Usage: bash node/npm-tools.sh [--list|--install|--dry-run|--help|--core|--full]

Review and install Node tools from the repo's canonical manifest.

Options:
  --list       Show the currently tracked Node tool list.
  --install    Install every tool in the manifest.
  --dry-run    Show what would be installed without installing it.
  --core       Use the smaller core Node tool profile.
  --full       Use the full Node tool profile.
  --help       Show this help text.

The tool list is sourced from .tools/common.sh to avoid drift.
EOF
}

list_tools() {
  echo "Node tool manifest:"
  echo "------------------"
  local index=1
  for tool in "${NODE_TOOLS[@]}"; do
    printf '%2s. %s\n' "$index" "$tool"
    index=$((index + 1))
  done
}

check_node() {
  if ! command -v node >/dev/null 2>&1; then
    echo "Error: node is not installed or is not in PATH." >&2
    echo "Install Node first, then rerun this script." >&2
    return 1
  fi

  if ! command -v npm >/dev/null 2>&1; then
    echo "Error: npm is not available for this Node installation." >&2
    echo "Install npm first, then rerun this script." >&2
    return 1
  fi
}

dry_run() {
  echo "Planned Node tool installs:"
  echo "--------------------------"
  for tool in "${NODE_TOOLS[@]}"; do
    echo "  npm install --global \"$tool\""
  done
}

install_tools() {
  check_node || return 1

  echo "Installing Node tools..."
  for tool in "${NODE_TOOLS[@]}"; do
    echo "Installing: $tool"
    npm install --global "$tool"
  done

  echo
  echo "Node tool installation complete."
}

main() {
  case "${1:-}" in
    --core)
      NODE_PACKAGE_PROFILE="core"
      NODE_TOOLS=("${NODE_CORE_PACKAGES[@]}")
      list_tools
      ;;
    --full)
      NODE_PACKAGE_PROFILE="full"
      NODE_TOOLS=("${NODE_FULL_PACKAGES[@]}")
      list_tools
      ;;
    --list)
      list_tools
      ;;
    --install)
      install_tools
      ;;
    --dry-run)
      dry_run
      ;;
    --help|-h|"")
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
}

main "$@"
