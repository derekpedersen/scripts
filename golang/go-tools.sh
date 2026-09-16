#!/usr/bin/env bash

# ============================================================
# Go tool manifest
# ============================================================
#
# Purpose:
#   Review and install the canonical Go tool list used by the repo's
#   shared installer without maintaining a second copy.
#
# Notes:
#   The canonical package list lives in .tools/common.sh. This script
#   reads that list so manual review/install flows cannot drift from
#   the repo's install bundle definitions.
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" && pwd)"
source "$SCRIPT_DIR/../.tools/common.sh"

GO_PACKAGE_PROFILE="${GO_PACKAGE_PROFILE:-full}"
if [[ "$GO_PACKAGE_PROFILE" == "core" ]]; then
  GO_TOOLS=("${GO_CORE_PACKAGES[@]}")
else
  GO_TOOLS=("${GO_FULL_PACKAGES[@]}")
fi

usage() {
  cat <<'EOF'
Usage: bash golang/go-tools.sh [--list|--install|--dry-run|--help|--core|--full]

Review and install Go tools from the repo's canonical manifest.

Options:
  --list       Show the currently tracked Go tool list.
  --install    Install every tool in the manifest.
  --dry-run    Show what would be installed without installing it.
  --core       Use the smaller core Go tool profile.
  --full       Use the full Go tool profile.
  --help       Show this help text.

The tool list is sourced from .tools/common.sh to avoid drift.
EOF
}

list_tools() {
  echo "Go tool manifest:"
  echo "----------------"
  local index=1
  for tool in "${GO_TOOLS[@]}"; do
    printf '%2s. %s\n' "$index" "$tool"
    index=$((index + 1))
  done
}

check_go() {
  if ! command -v go >/dev/null 2>&1; then
    echo "Error: go is not installed or is not in PATH." >&2
    echo "Install Go first, then rerun this script." >&2
    return 1
  fi
}

dry_run() {
  echo "Planned Go tool installs:"
  echo "------------------------"
  for tool in "${GO_TOOLS[@]}"; do
    echo "  go install \"$tool\""
  done
}

install_tools() {
  check_go || return 1

  echo "Installing Go tools..."
  for tool in "${GO_TOOLS[@]}"; do
    echo "Installing: $tool"
    go install "$tool"
  done

  echo
  echo "Go tool installation complete."
}

main() {
  case "${1:-}" in
    --core)
      GO_PACKAGE_PROFILE="core"
      GO_TOOLS=("${GO_CORE_PACKAGES[@]}")
      list_tools
      ;;
    --full)
      GO_PACKAGE_PROFILE="full"
      GO_TOOLS=("${GO_FULL_PACKAGES[@]}")
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
