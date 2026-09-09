$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$scriptPath = Join-Path $scriptDir 'install.sh'

if (-not (Test-Path $scriptPath)) {
    throw "Missing installer script: $scriptPath"
}

$bashCommand = Get-Command bash -ErrorAction SilentlyContinue
if (-not $bashCommand) {
    $gitBash = @(
        'C:\Program Files\Git\bin\bash.exe',
        'C:\Program Files\Git\usr\bin\bash.exe',
        'C:\msys64\usr\bin\bash.exe'
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $gitBash) {
        throw 'Git Bash is required to run the repo installer. Install Git for Windows or ensure bash is on PATH.'
    }

    $bashCommand = [pscustomobject]@{ Source = $gitBash }
}

$env:SCRIPTS_OS_OVERRIDE = 'Windows_NT'
& $bashCommand.Source $scriptPath @args
exit $LASTEXITCODE
