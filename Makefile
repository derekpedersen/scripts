SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

.PHONY: build test all

BUNDLES := default services cloud

all: build test

build:
	@bash -lc 'set -euo pipefail; \
		test -f bash.install.sh; \
		test -f bash.uninstall.sh; \
		test -d tools; \
		test -d helm; \
		for f in bash.*.sh; do echo "  - $$f"; bash -n "$$f"; done; \
		for f in tools/*.sh; do echo "  - $$f"; bash -n "$$f"; done; \
		for f in */install.sh */uninstall.sh */bash.sh; do if [[ -f "$$f" ]]; then echo "  - $$f"; bash -n "$$f"; fi; done; \
		for f in helm/*.sh; do echo "  - $$f"; bash -n "$$f"; done; \
		tmpdir=$$(mktemp -d); \
		chart_tmp="$$tmpdir/chart.yaml"; \
		printf "%s\n" \
			"apiVersion: v2" \
			"name: demo" \
			"description: temp fixture for CI validation" \
			"version: 0.1.0" \
			"appVersion: old" > "$$chart_tmp"; \
		expected_sha=$$(git rev-parse HEAD); \
		CHART_FILE="$$chart_tmp" bash ./helm/set-version.sh; \
		echo "Resulting chart fixture:"; \
		cat "$$chart_tmp"; \
		grep -Eq "^version: [0-9]{4}[.][0-9]{2}[.][0-9]{2}[.][0-9]{4}$$" "$$chart_tmp"; \
		grep -Eq "^appVersion: $${expected_sha}$$" "$$chart_tmp"; \
		rm -rf "$$tmpdir"'

test:
	@bash -lc 'set -euo pipefail; \
		for bundle in $(BUNDLES); do echo "Testing install bundle: $$bundle"; bash ./tools/install.sh "$$bundle" --dry-run; done; \
		for bundle in $(BUNDLES); do echo "Testing uninstall bundle: $$bundle"; bash ./tools/uninstall.sh "$$bundle" --dry-run; done'