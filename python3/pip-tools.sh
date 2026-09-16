#!/usr/bin/env bash

# ============================================================
# Python tool manifest
# ============================================================
#
# Purpose:
#   Keep a single reviewable list of Python tooling packages and
#   support review/install flows without changing the central
#   installer bundle.
#
# Notes:
#   Edit the PYTHON_TOOLS array to add or remove packages.
#   This script installs packages with the current user's Python
#   environment using pip.
# ============================================================

set -euo pipefail

PYTHON_TOOLS=(
  "pip-tools"
  "pipx"
  "virtualenv"
  "black"
  "ruff"
  "mypy"
  "pytest"
  "pre-commit"
  "requests"
  "boto3"
)

usage() {
  cat <<'EOF'
Usage: bash python3/pip-tools.sh [--list|--install|--dry-run|--help]

Review and install Python tools from a single manifest.

Options:
  --list       Show the currently tracked Python tool list.
  --install    Install every tool in the manifest.
  --dry-run    Show what would be installed without installing it.
  --help       Show this help text.

To update the manifest, edit the PYTHON_TOOLS array at the top of this file.
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
