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
      gpg)
        brew install gnupg
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
      gcloud|google-cloud)
        brew install --cask google-cloud-sdk
        ;;
      aws|awscli)
        brew install awscli
        ;;
      eksctl)
        brew install eksctl
        ;;
      az|azure|azure-cli)
        brew install azure-cli
        ;;
      doctl|digitalocean|doks)
        brew install doctl
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
      postgres)
        brew install postgresql@16
        echo "Postgres installed. Start it with: brew services start postgresql@16"
        ;;
      redis)
        brew install redis
        echo "Redis installed. Start it with: brew services start redis"
        ;;
      mysql)
        brew install mysql
        echo "MySQL installed. Start it with: brew services start mysql"
        ;;
      clickhouse)
        brew install clickhouse
        echo "ClickHouse installed. Start it with: clickhouse local or brew services start clickhouse"
        ;;
      mongodb)
        brew install mongodb-community
        echo "MongoDB installed. Start it with: brew services start mongodb-community"
        ;;
      rabbitmq)
        brew install rabbitmq
        echo "RabbitMQ installed. Start it with: brew services start rabbitmq"
        ;;
      elasticsearch)
        brew install elasticsearch
        echo "Elasticsearch installed. Start it with: brew services start elasticsearch"
        ;;
      kafka)
        brew install kafka
        echo "Kafka installed. Start it with: brew services start kafka"
        ;;
      *)
        echo "Unknown package for macOS: $pkg"
        ;;
    esac
  done
}
