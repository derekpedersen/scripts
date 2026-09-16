#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Module installer runtime
# ============================================================
#
# Purpose:
#   Provide shared install and uninstall dispatch helpers for per-tool
#   module scripts located at repo root (for example, git/install.sh).
#
# Notes:
#   This runtime keeps module scripts thin while preserving existing
#   platform-specific behavior from tools.macos.sh, tools.linux.sh,
#   and tools.windows.sh.
# ============================================================

TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" && pwd)"
REPO_ROOT="$TOOLS_DIR"

if [[ ! -f "$TOOLS_DIR/common.sh" ]]; then
  echo "Missing required helper: $TOOLS_DIR/common.sh"
  exit 1
fi

source "$TOOLS_DIR/common.sh"

OS_NAME="${SCRIPTS_OS_OVERRIDE:-$(uname -s)}"
PLATFORM=""
case "$OS_NAME" in
  Darwin)
    PLATFORM="mac"
    source "$TOOLS_DIR/macos.sh"
    ;;
  Linux)
    PLATFORM="linux"
    source "$TOOLS_DIR/linux.sh"
    ;;
  MINGW*|MSYS*|CYGWIN*|Windows_NT)
    PLATFORM="windows"
    source "$TOOLS_DIR/windows.sh"
    ;;
  *)
    if [[ -n "${WSL_DISTRO_NAME:-}" || "$(uname -r 2>/dev/null || true)" == *Microsoft* ]]; then
      PLATFORM="linux"
      source "$TOOLS_DIR/linux.sh"
    else
      echo "Unsupported OS: $OS_NAME"
      exit 1
    fi
    ;;
esac

module_install() {
  local tool="$(canonical_tool_name "$1")"

  case "$tool" in
    git-config)
      if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "DRY RUN: would configure Git identity."
      else
        configure_git_identity || true
      fi
      return 0
      ;;
    git-signing)
      if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "DRY RUN: would configure Git signing."
      else
        configure_git_signing || true
      fi
      return 0
      ;;
    ssh-key)
      if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "DRY RUN: would generate an SSH key."
      else
        configure_ssh_key || true
      fi
      return 0
      ;;
    identity)
      if [[ "${DRY_RUN:-false}" == true ]]; then
        echo "DRY RUN: would configure Git identity, GPG signing, and SSH key."
      else
        configure_identity_interactive "$REPO_ROOT/.tools/install.sh" || true
      fi
      return 0
      ;;
  esac

  if [[ "${DRY_RUN:-false}" == true ]]; then
    if [[ "$tool" == "python3" ]]; then
      local package_profile="${PYTHON_PACKAGE_PROFILE:-full}"
      local package_list=()

      if [[ "$package_profile" == "core" ]]; then
        package_list=("${PYTHON_CORE_PACKAGES[@]}")
      else
        package_list=("${PYTHON_FULL_PACKAGES[@]}")
      fi

      echo "DRY RUN: would install python3"
      echo "DRY RUN: would install Python developer packages:"
      printf '  - %s\n' "${package_list[@]}"
      return 0
    fi
    if [[ "$tool" == "golang" ]]; then
      local package_profile="${GO_PACKAGE_PROFILE:-full}"
      local package_list=()

      if [[ "$package_profile" == "core" ]]; then
        package_list=("${GO_CORE_PACKAGES[@]}")
      else
        package_list=("${GO_FULL_PACKAGES[@]}")
      fi

      echo "DRY RUN: would install golang"
      echo "DRY RUN: would install Go developer packages:"
      printf '  - %s\n' "${package_list[@]}"
      return 0
    fi
    if [[ "$tool" == "node" ]]; then
      local package_profile="${NODE_PACKAGE_PROFILE:-full}"
      local package_list=()

      if [[ "$package_profile" == "core" ]]; then
        package_list=("${NODE_CORE_PACKAGES[@]}")
      else
        package_list=("${NODE_FULL_PACKAGES[@]}")
      fi

      echo "DRY RUN: would install node"
      echo "DRY RUN: would install Node developer packages:"
      printf '  - %s\n' "${package_list[@]}"
      return 0
    fi
    echo "DRY RUN: would install $tool"
    return 0
  fi

  if [[ "$PLATFORM" == "mac" ]]; then
    install_mac "$tool"
  elif [[ "$PLATFORM" == "windows" ]]; then
    install_windows "$tool"
  else
    install_linux "$tool"
  fi
}

module_uninstall() {
  local tool="$(canonical_tool_name "$1")"

  if [[ "${DRY_RUN:-false}" == true ]]; then
    echo "DRY RUN: would uninstall $tool"
    return 0
  fi

  if [[ -f "$REPO_ROOT/.tools/uninstall.sh" ]]; then
    TOOLS_UNINSTALL_MODULE_INTERNAL=1 bash "$REPO_ROOT/.tools/uninstall.sh" "$tool"
  else
    echo "Missing required script: $REPO_ROOT/.tools/uninstall.sh"
    return 1
  fi
}
