#!/usr/bin/env bash

# ============================================================
# Google Cloud helpers
# ============================================================
#
# Purpose:
#   Shortcuts for common GCP and GKE workflows while developing.
#
# Notes:
#   Prefer plain, discoverable commands over clever aliases.
# ============================================================

gcloud-project() {
  gcloud config get-value project 2>/dev/null || echo "No active GCP project configured"
}

gcloud-set-project() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: gcloud-set-project <project-id>"
    return 1
  fi

  gcloud config set project "$1"
}

gcloud-set-region() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: gcloud-set-region <region>"
    return 1
  fi

  gcloud config set compute/region "$1"
}

gcloud-clusters() {
  gcloud container clusters list --format='table(name, location, status)'
}

gcloud-projects() {
  gcloud projects list --format='table(projectId,name,projectNumber)'
}

gcloud-logs() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: gcloud-logs <filter> [gcloud logging options]"
    return 1
  fi

  gcloud logging read "$@" --limit 20
}

gcloud-iam() {
  gcloud iam service-accounts list --format='table(email,displayName)'
}

gcloud-auth() {
  gcloud auth login
}

gcloud-kubeconfig() {
  if [[ -z "${1:-}" ]]; then
    echo "Usage: gcloud-kubeconfig <cluster-name> [region]"
    return 1
  fi

  local cluster_name="$1"
  local region="${2:-$(gcloud config get-value compute/region 2>/dev/null || echo us-central1)}"
  gcloud container clusters get-credentials "$cluster_name" --region "$region"
}
