#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Tool installer controller
# ============================================================
#
# Purpose:
#   Dispatch install requests to the appropriate OS-specific logic and
#   keep bundle installs consistent across macOS and Debian-based Linux.
#
# Notes:
#   This script intentionally stays thin; platform-specific logic lives in
#   tools/macos.sh and tools/linux.sh.
# ============================================================

bootstrap_from_github() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to bootstrap installer files from GitHub."
    return 1
  fi

  local repo="${SCRIPTS_REPO:-derekpedersen/scripts}"
  local ref="${SCRIPTS_REF:-main}"
  local tmpdir
  local archive
  local extracted_dir
  local rc

  tmpdir="$(mktemp -d)"
  archive="$tmpdir/scripts.tar.gz"

  echo "Bootstrapping tools installer from github.com/$repo ($ref)..."
  curl -fsSL "https://codeload.github.com/$repo/tar.gz/refs/heads/$ref" -o "$archive"
  tar -xzf "$archive" -C "$tmpdir"

  extracted_dir="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  if [[ -z "$extracted_dir" || ! -f "$extracted_dir/tools/install.sh" ]]; then
    echo "Bootstrap failed: could not find tools/install.sh in downloaded archive."
    rm -rf "$tmpdir"
    return 1
  fi

  SCRIPTS_BOOTSTRAPPED=1 SCRIPTS_REF="$ref" SCRIPTS_REPO="$repo" bash "$extracted_dir/tools/install.sh" "$@"
  rc=$?
  rm -rf "$tmpdir"
  return $rc
}

# BASH_SOURCE is unset when piped via curl; fall back to cwd so bootstrap runs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" && pwd)"

if [[ ! -f "$SCRIPT_DIR/common.sh" || ! -f "$SCRIPT_DIR/macos.sh" || ! -f "$SCRIPT_DIR/linux.sh" ]]; then
  if [[ "${SCRIPTS_BOOTSTRAPPED:-0}" == "1" ]]; then
    echo "Required installer files are missing from $SCRIPT_DIR and bootstrap already ran."
    exit 1
  fi

  bootstrap_from_github "$@"
  exit $?
fi

source "$SCRIPT_DIR/common.sh"

OS="$(uname -s)"
case "$OS" in
  Darwin)
    source "$SCRIPT_DIR/macos.sh"
    PLATFORM="mac"
    ;;
  Linux)
    source "$SCRIPT_DIR/linux.sh"
    PLATFORM="linux"
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

DRY_RUN=false
args=()
for arg in "$@"; do
  case "$arg" in
    --dry-run|-n)
      DRY_RUN=true
      ;;
    *)
      args+=("$arg")
      ;;
  esac
done

if [[ ${#args[@]} -eq 0 ]]; then
  echo "Usage: $0 [default|full|dev|services|cloud|<tool> [tool ...]] [--dry-run]"
  echo "Bundled install options:"
  echo "  default  = git, curl, wget, python3, nvm, node, golang, kubectl, helm, docker, dotnetcore, vscode"
  echo "  full/dev = default + gcloud, awscli, eksctl, az, doctl, jq, yq, postgres, redis, mysql, clickhouse, mongodb, rabbitmq"
  echo "  services = postgres, redis, mysql, clickhouse, mongodb, rabbitmq, elasticsearch, kafka"
  echo "  cloud    = gcloud, awscli, eksctl, az, doctl, jq, yq"
  echo "Direct tool options include: git, gpg, curl, wget, unzip, python3, nvm, node, golang, kubectl, helm, docker, dotnetcore, vscode, gcloud, aws, awscli, eksctl, az, azure, doctl, digitalocean, jq, yq, postgres, redis, mysql, clickhouse, mongodb, rabbitmq, elasticsearch, kafka, git-config, git-signing, ssh-key, identity"
  echo "Git/GPG and SSH setup: export GIT_USER_NAME, GIT_USER_EMAIL, and optionally GPG_KEY_ID / SSH_KEY_EMAIL before running:"
  echo "  GIT_USER_NAME='Jane Doe' GIT_USER_EMAIL='jane@example.com' GPG_KEY_ID='ABC123DEF456' $0 gpg git-config git-signing"
  echo "  SSH_KEY_EMAIL='jane@example.com' $0 ssh-key"
  echo "  GIT_USER_NAME='Jane Doe' GIT_USER_EMAIL='jane@example.com' SSH_KEY_EMAIL='jane@example.com' $0 identity"
  echo "Interactive setup: $0 identity"
  echo "Examples:"
  echo "  $0 default"
  echo "  $0 full"
  echo "  $0 services"
  echo "  $0 cloud"
  echo "  $0 git nvm kubectl helm docker"
  echo "  $0 gcloud awscli eksctl az doctl"
  exit 1
fi

BUNDLE_MODE=""
if [[ ${#args[@]} -gt 0 ]] && { [[ "${args[0]}" == "default" ]] || [[ "${args[0]}" == "full" ]] || [[ "${args[0]}" == "dev" ]] || [[ "${args[0]}" == "services" ]] || [[ "${args[0]}" == "cloud" ]]; }; then
  BUNDLE_MODE="${args[0]}"
  if [[ ${#args[@]} -gt 1 ]]; then
    args=("${args[@]:1}")
  else
    args=()
  fi
fi

if [[ " ${args[*]:-} " == *" git-signing "* ]]; then
  if ! printf '%s\n' "${args[@]}" | grep -qx 'gpg'; then
    args+=("gpg")
  fi
fi

if [[ " ${args[*]:-} " == *" ssh-key "* ]]; then
  if ! printf '%s\n' "${args[@]}" | grep -qx 'ssh-key'; then
    args+=("ssh-key")
  fi
fi

if [[ " ${args[*]:-} " == *" identity "* ]]; then
  if ! printf '%s\n' "${args[@]}" | grep -qx 'git-config'; then
    args+=("git-config")
  fi
  if ! printf '%s\n' "${args[@]}" | grep -qx 'git-signing'; then
    args+=("git-signing")
  fi
  if ! printf '%s\n' "${args[@]}" | grep -qx 'ssh-key'; then
    args+=("ssh-key")
  fi

  filtered_identity=()
  for item in "${args[@]}"; do
    if [[ "$item" != "identity" ]]; then
      filtered_identity+=("$item")
    fi
  done
  args=("${filtered_identity[@]}")
fi

if [[ -n "$BUNDLE_MODE" ]]; then
  case "$BUNDLE_MODE" in
    default)
      if [[ ${#args[@]} -gt 0 ]]; then
        args=("${DEFAULT_BUNDLE[@]}" "${args[@]}")
      else
        args=("${DEFAULT_BUNDLE[@]}")
      fi
      ;;
    full|dev)
      if [[ ${#args[@]} -gt 0 ]]; then
        args=("${FULL_BUNDLE[@]}" "${args[@]}")
      else
        args=("${FULL_BUNDLE[@]}")
      fi
      ;;
    services)
      if [[ ${#args[@]} -gt 0 ]]; then
        args=("${SERVICES_BUNDLE[@]}" "${args[@]}")
      else
        args=("${SERVICES_BUNDLE[@]}")
      fi
      ;;
    cloud)
      if [[ ${#args[@]} -gt 0 ]]; then
        args=("${CLOUD_BUNDLE[@]}" "${args[@]}")
      else
        args=("${CLOUD_BUNDLE[@]}")
      fi
      ;;
  esac
fi

filtered_args=()
for item in "${args[@]}"; do
  case "$item" in
    git-config)
      if [[ "$DRY_RUN" != true ]]; then
        configure_git_identity || true
      else
        echo "DRY RUN: would configure Git identity."
      fi
      ;;
    git-signing)
      if [[ "$DRY_RUN" != true ]]; then
        configure_git_signing || true
      else
        echo "DRY RUN: would configure Git signing."
      fi
      ;;
    ssh-key)
      if [[ "$DRY_RUN" != true ]]; then
        configure_ssh_key || true
      else
        echo "DRY RUN: would generate an SSH key."
      fi
      ;;
    identity)
      if [[ "$DRY_RUN" != true ]]; then
        configure_identity_interactive "$0" || true
      else
        echo "DRY RUN: would configure Git identity, GPG signing, and SSH key."
      fi
      ;;
    *)
      filtered_args+=("$item")
      ;;
  esac
done
args=("${filtered_args[@]:-}")

if [[ "$DRY_RUN" == true ]]; then
  echo "DRY RUN: would install the following packages/tools:"
  if ((${#args[@]} > 0)); then
    printf '  - %s\n' "${args[@]}"
  else
    echo "  - none"
  fi
  exit 0
fi

if [[ "$PLATFORM" == "mac" ]]; then
  install_mac "${args[@]}"
else
  install_linux "${args[@]}"
fi

for item in "${args[@]}"; do
  case "$item" in
    git-config)
      configure_git_identity || true
      ;;
    git-signing)
      configure_git_signing || true
      ;;
    ssh-key)
      configure_ssh_key || true
      ;;
    identity)
      configure_identity_interactive "$0" || true
      ;;
  esac
done
