#!/usr/bin/env bash
set -euo pipefail

install_mac() {
  echo "Detected macOS"

  if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$('/opt/homebrew/bin/brew shellenv')"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$('/usr/local/bin/brew shellenv')"
    fi
  fi

  for pkg in "$@"; do
    case "$pkg" in
      git)
        brew install git
        ;;
      helm)
        brew install helm
        ;;
      kubectl)
        brew install kubectl
        ;;
      kubernetes-cli)
        brew install kubectl
        ;;
      docker)
        echo "Docker Desktop is typically installed via the official app, not Homebrew."
        echo "Install it from: https://www.docker.com/products/docker-desktop/"
        ;;
      golang)
        brew install go
        ;;
      nvm)
        echo "Installing nvm..."
        if ! [ -d "$HOME/.nvm" ]; then
          curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        fi
        export NVM_DIR="$HOME/.nvm"
        if [ -s "$NVM_DIR/nvm.sh" ]; then
          . "$NVM_DIR/nvm.sh"
          if ! command -v node >/dev/null 2>&1; then
            nvm install --lts
          fi
          nvm alias default lts/* >/dev/null 2>&1 || true
        fi
        ;;
      node)
        echo "Installing Node LTS via nvm..."
        export NVM_DIR="$HOME/.nvm"
        if ! [ -s "$NVM_DIR/nvm.sh" ]; then
          curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
        fi
        if [ -s "$NVM_DIR/nvm.sh" ]; then
          . "$NVM_DIR/nvm.sh"
          if ! command -v node >/dev/null 2>&1; then
            nvm install --lts
          fi
          nvm alias default lts/* >/dev/null 2>&1 || true
        fi
        ;;
      dotnetcore)
        brew install --cask dotnet-sdk
        ;;
      dotnet)
        brew install --cask dotnet-sdk
        ;;
      vscode|code)
        brew install --cask visual-studio-code
        ;;
      curl)
        echo "curl is already included with macOS."
        ;;
      unzip)
        brew install unzip
        ;;
      wget)
        brew install wget
        ;;
      python3)
        brew install python
        ;;
      *)
        echo "Unknown package for macOS: $pkg"
        ;;
    esac
  done
}
