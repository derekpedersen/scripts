#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_FILE="${CHART_FILE:-$SCRIPT_DIR/../.helm/Chart.yaml}"

if [[ ! -f "$CHART_FILE" ]]; then
	echo "Chart file not found: $CHART_FILE"
	exit 1
fi

VERSION="$(date '+%Y.%m.%d.%H%M')"
APP_VERSION="$(git rev-parse HEAD)"

tmp_file="$(mktemp)"

awk -v version="$VERSION" -v appVersion="$APP_VERSION" '
	BEGIN {
		saw_version = 0
		saw_app_version = 0
	}
	/^version:[[:space:]]*/ {
		print "version: " version
		saw_version = 1
		next
	}
	/^appVersion:[[:space:]]*/ {
		print "appVersion: " appVersion
		saw_app_version = 1
		next
	}
	{ print }
	END {
		if (!saw_version) {
			print "version: " version
		}
		if (!saw_app_version) {
			print "appVersion: " appVersion
		}
	}
' "$CHART_FILE" > "$tmp_file"

mv "$tmp_file" "$CHART_FILE"

echo "Updated $CHART_FILE"
echo "version: $VERSION"
echo "appVersion: $APP_VERSION"