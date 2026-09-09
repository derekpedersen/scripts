#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Tool installer uninstaller
# ============================================================
#
# Purpose:
#   Reverse the repo's managed tool installation flow for explicit tool or
#   bundle names without touching unrelated system state.
#
# Notes:
#   This script intentionally mirrors the install pattern: explicit targets,
#   bundle support, and dry-run safety. It only removes tools managed by this
#   repository or simple package-manager installs.
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" && pwd)"
if [[ ! -f "$SCRIPT_DIR/common.sh" ]]; then
  echo "Required installer file missing: $SCRIPT_DIR/common.sh"
  exit 1
fi

source "$SCRIPT_DIR/common.sh"

usage() {
  cat <<'EOF'
Usage: bash ./tools/uninstall.sh [default|full|dev|services|cloud|<tool> [tool ...]] [--dry-run]

Bundle targets:
  default  = git, curl, wget, python3, nvm, node, golang, kubectl, helm, docker, dotnetcore, vscode
  full/dev = default + gcloud, awscli, eksctl, az, doctl, jq, yq, postgres, redis, mysql, clickhouse, mongodb, rabbitmq
  services = postgres, redis, mysql, clickhouse, mongodb, rabbitmq, elasticsearch, kafka
  cloud    = gcloud, awscli, eksctl, az, doctl, jq, yq

Examples:
  bash ./tools/uninstall.sh default
  bash ./tools/uninstall.sh kubectl docker --dry-run
  bash ./tools/uninstall.sh services
EOF
}

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
  usage
  exit 1
fi

expand_bundle() {
  local item="$1"
  case "$item" in
    default)
      printf '%s\n' "${DEFAULT_BUNDLE[@]}"
      ;;
    full|dev)
      printf '%s\n' "${FULL_BUNDLE[@]}"
      ;;
    services)
      printf '%s\n' "${SERVICES_BUNDLE[@]}"
      ;;
    cloud)
      printf '%s\n' "${CLOUD_BUNDLE[@]}"
      ;;
    *)
      printf '%s\n' "$item"
      ;;
  esac
}

resolve_targets() {
  local expanded=()
  local item
  for item in "$@"; do
    while IFS= read -r expanded_item; do
      [[ -z "$expanded_item" ]] && continue
      expanded+=("$expanded_item")
    done < <(expand_bundle "$item")
  done

  local result=()
  for item in "${expanded[@]}"; do
    local seen_item
    local already_seen=false
    if [[ ${#result[@]} -gt 0 ]]; then
      for seen_item in "${result[@]}"; do
        if [[ "$seen_item" == "$item" ]]; then
          already_seen=true
          break
        fi
      done
    fi

    if [[ "$already_seen" == false ]]; then
      result+=("$item")
    fi
  done

  if [[ ${#result[@]} -gt 0 ]]; then
    printf '%s\n' "${result[@]}"
  fi
}

remove_git_identity_config() {
  if git config --global --get user.name >/dev/null 2>&1; then
    git config --global --unset-all user.name || true
  fi
  if git config --global --get user.email >/dev/null 2>&1; then
    git config --global --unset-all user.email || true
  fi
}

remove_git_signing_config() {
  git config --global --unset-all commit.gpgsign || true
  git config --global --unset-all tag.gpgSign || true
  git config --global --unset-all gpg.program || true
  git config --global --unset-all user.signingkey || true
}

remove_ssh_key() {
  local key_path="${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"
  rm -f "$key_path" "$key_path.pub"
}

remove_apt_package() {
  local pkg="$1"
  local binary_name="${2:-$1}"
  local sudo_cmd=""

  if command -v sudo >/dev/null 2>&1 && [[ "$(id -u)" != "0" ]]; then
    sudo_cmd="sudo"
  fi

  if ! dpkg -s "$pkg" >/dev/null 2>&1 && ! command -v "$binary_name" >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    if [[ -n "$sudo_cmd" ]]; then
      echo "DRY RUN: $sudo_cmd apt-get purge -y $pkg"
    else
      echo "DRY RUN: apt-get purge -y $pkg"
    fi
    return 0
  fi

  if [[ -n "$sudo_cmd" ]]; then
    $sudo_cmd apt-get purge -y "$pkg"
  else
    apt-get purge -y "$pkg"
  fi
}

remove_binary() {
  local binary="$1"
  local path
  path="$(command -v "$binary" 2>/dev/null || true)"

  if [[ -z "$path" ]]; then
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY RUN: rm -f $path"
    return 0
  fi

  rm -f "$path"
}

remove_homebrew_package() {
  local pkg="$1"
  if ! command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "DRY RUN: brew uninstall --force $pkg"
    return 0
  fi

  brew uninstall --force "$pkg" || true
}

uninstall_tool() {
  local tool="$1"

  case "$tool" in
    git)
      remove_apt_package "git" "git"
      ;;
    gpg)
      remove_apt_package "gnupg" "gpg"
      ;;
    curl)
      remove_apt_package "curl" "curl"
      ;;
    wget)
      remove_apt_package "wget" "wget"
      ;;
    unzip)
      remove_apt_package "unzip" "unzip"
      ;;
    python3)
      remove_apt_package "python3" "python3"
      ;;
    git-config)
      if [[ "$DRY_RUN" == true ]]; then
        echo "DRY RUN: would clear global Git identity config"
      else
        remove_git_identity_config
      fi
      ;;
    git-signing)
      if [[ "$DRY_RUN" == true ]]; then
        echo "DRY RUN: would clear Git signing config"
      else
        remove_git_signing_config
      fi
      ;;
    ssh-key)
      if [[ "$DRY_RUN" == true ]]; then
        echo "DRY RUN: would remove SSH key at ${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519}"
      else
        remove_ssh_key
      fi
      ;;
    identity)
      if [[ "$DRY_RUN" == true ]]; then
        echo "DRY RUN: would clear Git identity, signing, and SSH key config"
      else
        remove_git_identity_config
        remove_git_signing_config
        remove_ssh_key
      fi
      ;;
    nvm)
      if [[ "$DRY_RUN" == true ]]; then
        echo "DRY RUN: would remove $HOME/.nvm"
      else
        rm -rf "$HOME/.nvm"
      fi
      ;;
    node)
      if [[ "$DRY_RUN" == true ]]; then
        echo "DRY RUN: would remove node and nvm-managed Node installs"
      else
        rm -rf "$HOME/.nvm"
      fi
      ;;
    golang)
      remove_binary "go"
      if [[ -d "/usr/local/go" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
          echo "DRY RUN: would remove /usr/local/go"
        else
          rm -rf /usr/local/go
        fi
      fi
      ;;
    helm)
      remove_binary "helm"
      if [[ -f "/usr/local/bin/helm" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
          echo "DRY RUN: would remove /usr/local/bin/helm"
        else
          rm -f /usr/local/bin/helm
        fi
      fi
      ;;
    kubectl|kubernetes-cli)
      remove_binary "kubectl"
      if [[ -f "/usr/local/bin/kubectl" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
          echo "DRY RUN: would remove /usr/local/bin/kubectl"
        else
          rm -f /usr/local/bin/kubectl
        fi
      fi
      ;;
    docker)
      remove_apt_package "docker-ce" "docker"
      remove_apt_package "docker-ce-cli" "docker"
      remove_apt_package "containerd.io" "containerd"
      remove_apt_package "docker-buildx-plugin" "docker-buildx"
      remove_apt_package "docker-compose-plugin" "docker-compose"
      ;;
    dotnetcore|dotnet)
      remove_apt_package "dotnet-sdk-8.0" "dotnet"
      remove_binary "dotnet"
      ;;
    vscode|code)
      remove_apt_package "code" "code"
      remove_binary "code"
      ;;
    gcloud|google-cloud)
      remove_apt_package "google-cloud-cli" "gcloud"
      remove_binary "gcloud"
      ;;
    aws|awscli)
      remove_apt_package "awscli" "aws"
      remove_binary "aws"
      ;;
    eksctl)
      remove_binary "eksctl"
      ;;
    az|azure|azure-cli)
      remove_apt_package "azure-cli" "az"
      remove_binary "az"
      ;;
    doctl|digitalocean|doks)
      remove_binary "doctl"
      ;;
    jq)
      remove_apt_package "jq" "jq"
      ;;
    yq)
      remove_binary "yq"
      ;;
    postgres)
      remove_apt_package "postgresql" "psql"
      ;;
    redis)
      remove_apt_package "redis-server" "redis-server"
      ;;
    mysql)
      remove_apt_package "mysql-server" "mysqld"
      ;;
    clickhouse)
      remove_apt_package "clickhouse-server" "clickhouse-server"
      ;;
    mongodb)
      remove_apt_package "mongodb-org" "mongod"
      ;;
    rabbitmq)
      remove_apt_package "rabbitmq-server" "rabbitmq-server"
      ;;
    elasticsearch)
      remove_apt_package "elasticsearch" "elasticsearch"
      ;;
    kafka)
      remove_apt_package "kafka" "kafka"
      ;;
    *)
      echo "Unsupported tool: $tool"
      ;;
  esac
}

TARGETS=$(resolve_targets "${args[@]}")
TARGET_LIST=()
while IFS= read -r target; do
  [[ -z "$target" ]] && continue
  TARGET_LIST+=("$target")
done < <(printf '%s\n' "$TARGETS")

if [[ ${#TARGET_LIST[@]} -eq 0 ]]; then
  usage
  exit 1
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "DRY RUN: would uninstall the following tools:"
  printf '  - %s\n' "${TARGET_LIST[@]}"
  exit 0
fi

for tool in "${TARGET_LIST[@]}"; do
  uninstall_tool "$tool"
done

echo "Uninstall complete for: ${TARGET_LIST[*]}"
