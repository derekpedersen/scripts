#!/usr/bin/env bash

# ============================================================
# Cloud helper bundle
# ============================================================
#
# Purpose:
#   Convenience wrapper for the multi-cloud helper set used in local
#   development environments.
#
# Notes:
#   This file is intentionally lightweight; the cloud-specific helper
#   files are sourced separately by bash/install.sh.
# ============================================================

if command -v aws >/dev/null 2>&1; then
  :
fi

# The individual files are auto-sourced by bash/install.sh when enabled.
# This file intentionally keeps the cloud-related shortcuts grouped together.

cloud-status() {
  echo "Cloud tools available:"
  for tool in aws gcloud az doctl; do
    if command -v "$tool" >/dev/null 2>&1; then
      echo "  - $tool"
    else
      echo "  - $tool (not installed)"
    fi
  done
}
