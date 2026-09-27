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

bootstrap_from_github() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to bootstrap installer files from GitHub."
    return 1
  fi

  local repo="${TOOL_SHED_REPO:-derekpedersen/tool-shed}"
  local ref="${TOOL_SHED_REF:-main}"
  local tmpdir
  local archive
  local extracted_dir
  local rc

  tmpdir="$(mktemp -d)"
  archive="$tmpdir/tool-shed.tar.gz"

  echo "Bootstrapping tool-shed root installer from github.com/$repo ($ref)..."
  curl -fsSL "https://codeload.github.com/$repo/tar.gz/refs/heads/$ref" -o "$archive"
  tar -xzf "$archive" -C "$tmpdir"

  extracted_dir="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  if [[ -z "$extracted_dir" || ! -f "$extracted_dir/install.sh" ]]; then
    echo "Bootstrap failed: could not find install.sh in downloaded archive."
    rm -rf "$tmpdir"
    return 1
  fi

  TOOL_SHED_BOOTSTRAPPED=1 TOOL_SHED_REF="$ref" TOOL_SHED_REPO="$repo" bash "$extracted_dir/install.sh" "$@"
  rc=$?
  rm -rf "$tmpdir"
  return $rc
}

# BASH_SOURCE can be unavailable when piped via curl; use $0 as a fallback.
SCRIPT_PATH="${BASH_SOURCE:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/.bash/install.sh" || ! -f "$SCRIPT_DIR/.tools/install.sh" ]]; then
  if [[ "${TOOL_SHED_BOOTSTRAPPED:-0}" == "1" ]]; then
    echo "Required installer files are missing from $SCRIPT_DIR and bootstrap already ran."
    exit 1
  fi

  bootstrap_from_github "$@"
  exit $?
fi

HAS_TTY=false
if [[ -r /dev/tty && -w /dev/tty ]]; then
  HAS_TTY=true
fi

confirm() {
  local prompt="$1"
  local default="${2:-y}"
  local answer

  if [[ "$HAS_TTY" != true ]]; then
    [[ "$default" == "y" ]]
    return
  fi

  if [[ "$default" == "y" ]]; then
    read -r -u 3 -p "$prompt [Y/n]: " answer
    answer="${answer:-Y}"
  else
    read -r -u 3 -p "$prompt [y/N]: " answer
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

  if [[ "$HAS_TTY" != true ]]; then
    printf '%s\n' "$target"
    return
  fi

  echo "Choose tools install target (default/full/dev/services/cloud/python-ai or specific tools):" > /dev/tty
  read -r -u 3 -p "Target [default]: " input
  printf '%s\n' "${input:-$target}"
}

if [[ "$HAS_TTY" == true ]]; then
  exec 3<>/dev/tty
fi

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

if [[ "$HAS_TTY" == true ]]; then
  exec 3>&-
fi