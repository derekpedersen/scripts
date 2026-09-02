#!/usr/bin/env bash

# Azure CLI helpers.

az-subscriptions() {
  az account list --output table
}

az-current-subscription() {
  az account show --output table
}

az-set-subscription() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: az-set-subscription <subscription-name-or-id>"
    return 1
  fi

  az account set --subscription "$1"
}

az-rg-list() {
  az group list --output table "$@"
}

az-kubeconfig() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: az-kubeconfig <resource-group> <cluster-name>"
    return 1
  fi

  az aks get-credentials --resource-group "$1" --name "$2"
}

az-login-shell() {
  az login "$@"
}
