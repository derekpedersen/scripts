#!/usr/bin/env bash
set -euo pipefail

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

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 [default|full|dev|<tool> [tool ...]]"
  echo "Examples:"
  echo "  $0 default"
  echo "  $0 full"
  echo "  $0 git nvm kubectl helm docker"
  exit 1
fi

BUNDLE_MODE=""
if [[ "$1" == "default" || "$1" == "full" || "$1" == "dev" ]]; then
  BUNDLE_MODE="$1"
  shift
fi

if [[ -n "$BUNDLE_MODE" ]]; then
  case "$BUNDLE_MODE" in
    default)
      set -- "${DEFAULT_BUNDLE[@]}" "$@"
      ;;
    full|dev)
      set -- "${FULL_BUNDLE[@]}" "$@"
      ;;
  esac
fi

if [[ "$PLATFORM" == "mac" ]]; then
  install_mac "$@"
else
  install_linux "$@"
fi
