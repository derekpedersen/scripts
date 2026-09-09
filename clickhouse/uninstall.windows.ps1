$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Resolve-Path (Join-Path $scriptDir '..')
$installer = Join-Path $repoRoot 'tools/uninstall.ps1'

if (-not (Test-Path $installer)) {
    throw "Missing uninstaller script: $installer"
}

& $installer 'clickhouse' @args
exit $LASTEXITCODE
