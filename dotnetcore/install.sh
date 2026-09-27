#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" && pwd)"
source "$SCRIPT_DIR/../.tools/module-runtime.sh"

install_dotnetcore_powershell_tool_if_missing() {
	local os_name
	os_name="$(uname -s)"

	case "$os_name" in
		Darwin|Linux)
			;;
		*)
			return 0
			;;
	esac

	if [[ "${DRY_RUN:-false}" == true ]]; then
		echo "DRY RUN: would install PowerShell via dotnet global tool if missing."
		return 0
	fi

	export PATH="$PATH:$HOME/.dotnet/tools"

	if ! command -v dotnet >/dev/null 2>&1; then
		echo "dotnet CLI not available; skipping PowerShell .NET tool install."
		return 0
	fi

	if command -v pwsh >/dev/null 2>&1; then
		return 0
	fi

	if dotnet tool list --global 2>/dev/null | awk 'NR > 2 {print tolower($1)}' | grep -qx "powershell"; then
		return 0
	fi

	echo "Installing PowerShell via dotnet global tool..."
	dotnet tool install --global PowerShell
}

module_install "dotnetcore"
install_dotnetcore_powershell_tool_if_missing
