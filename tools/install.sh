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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
  echo "Direct tool options include: git, curl, wget, unzip, python3, nvm, node, golang, kubectl, helm, docker, dotnetcore, vscode, gcloud, aws, awscli, eksctl, az, azure, doctl, digitalocean, jq, yq, postgres, redis, mysql, clickhouse, mongodb, rabbitmq, elasticsearch, kafka"
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

if [[ "$DRY_RUN" == true ]]; then
  echo "DRY RUN: would install the following packages/tools:"
  printf '  - %s\n' "${args[@]}"
  exit 0
fi

if [[ "$PLATFORM" == "mac" ]]; then
  install_mac "${args[@]}"
else
  install_linux "${args[@]}"
fi
