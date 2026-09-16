#!/usr/bin/env bash

# ============================================================
# Python tool manifest
# ============================================================
#
# Purpose:
#   Review and install the canonical Python tool list used by the
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

PYTHON_PACKAGE_PROFILE="${PYTHON_PACKAGE_PROFILE:-full}"
if [[ "$PYTHON_PACKAGE_PROFILE" == "core" ]]; then
  PYTHON_TOOLS=("${PYTHON_CORE_PACKAGES[@]}")
else
  PYTHON_TOOLS=("${PYTHON_FULL_PACKAGES[@]}")
fi

usage() {
  cat <<'EOF'
Usage: bash python3/pip-tools.sh [--list|--install|--dry-run|--help|--core|--full]

Review and install Python tools from the repo's canonical manifest.

Options:
  --list       Show the currently tracked Python tool list.
  --install    Install every tool in the manifest.
  --dry-run    Show what would be installed without installing it.
  --core       Use the smaller core Python tool profile.
  --full       Use the full Python tool profile.
  --help       Show this help text.

The tool list is sourced from .tools/common.sh to avoid drift.
EOF
}

list_tools() {
  echo "Python tool manifest:"
  echo "---------------------"
  local index=1
  for tool in "${PYTHON_TOOLS[@]}"; do
    printf '%2s. %s\n' "$index" "$tool"
    index=$((index + 1))
  done
}

check_python() {
  if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is not installed or is not in PATH." >&2
    echo "Install Python first, then rerun this script." >&2
    return 1
  fi

  if ! python3 -m pip --version >/dev/null 2>&1; then
    echo "Error: pip is not available for python3." >&2
    echo "Install Python with pip support before using this tool manifest." >&2
    return 1
  fi
}

dry_run() {
  echo "Planned Python tool installs:"
  echo "----------------------------"
  for tool in "${PYTHON_TOOLS[@]}"; do
    echo "  python3 -m pip install --user \"$tool\""
  done
}

install_tools() {
  check_python || return 1

  echo "Installing Python tools..."
  for tool in "${PYTHON_TOOLS[@]}"; do
    echo "Installing: $tool"
    python3 -m pip install --user "$tool"
  done

  echo
  echo "Python tool installation complete."
}

main() {
  case "${1:-}" in
    --core)
      PYTHON_PACKAGE_PROFILE="core"
      PYTHON_TOOLS=("${PYTHON_CORE_PACKAGES[@]}")
      list_tools
      ;;
    --full)
      PYTHON_PACKAGE_PROFILE="full"
      PYTHON_TOOLS=("${PYTHON_FULL_PACKAGES[@]}")
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
