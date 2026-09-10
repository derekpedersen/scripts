#!/usr/bin/env bash

# ============================================================
# Helm helpers
# ============================================================
#
# Purpose:
#   Small shell shortcuts for the repo's Helm chart version helpers.
#
# Notes:
#   Source this file via bash.install.sh to make the helpers available
#   in your shell.
# ============================================================

helm-set-version() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" && pwd)"
  local chart_file="${1:-${CHART_FILE:-${PWD}/.helm/Chart.yaml}}"

  CHART_FILE="$chart_file" bash "$script_dir/set-version.sh"
}

helm-show-version() {
  local chart_file="${1:-${CHART_FILE:-${PWD}/.helm/Chart.yaml}}"

  if [[ ! -f "$chart_file" ]]; then
    echo "Chart file not found: $chart_file" >&2
    return 1
  fi

  awk '/^(version|appVersion):/ {print}' "$chart_file"
}
