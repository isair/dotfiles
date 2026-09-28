param([Parameter(Mandatory=$true)][string]$PackagesPath)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Common.ps1"

$scoopfile = Join-Path $PackagesPath 'scoopfile.json'
$legacyScoop = Join-Path $PackagesPath 'scoop.txt'
if ((Test-Path -LiteralPath $scoopfile -PathType Leaf) -or (Test-Path -LiteralPath $legacyScoop -PathType Leaf)) {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        # Scoop's supported per-user installer; no persistent policy change or elevation.
        Invoke-Expression (Invoke-RestMethod 'https://get.scoop.sh')
        if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
            throw 'Scoop installation did not make scoop available. See https://scoop.sh.'
        }
    }
    if (Test-Path -LiteralPath $scoopfile -PathType Leaf) {
        $manifest = Get-Content -LiteralPath $scoopfile -Raw -Encoding UTF8 | ConvertFrom-Json -ErrorAction Stop
        if ($null -eq $manifest.apps -or $null -eq $manifest.buckets) { throw 'Invalid scoopfile.json.' }
        $global:LASTEXITCODE = 0
        & scoop import $scoopfile
        Assert-CommandSucceeded 'scoop import'
    } else {
        foreach ($package in Get-ManifestLines $legacyScoop) {
            $global:LASTEXITCODE = 0
            & scoop install $package
            Assert-CommandSucceeded "scoop install $package"
        }
    }
}

$npmManifest = Join-Path $PackagesPath 'npm.txt'
if (Test-Path -LiteralPath $npmManifest -PathType Leaf) {
    $packages = @(Get-ManifestLines $npmManifest)
    if ($packages.Count -gt 0) {
        if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { throw 'npm.txt exists but npm is unavailable.' }
        $global:LASTEXITCODE = 0
        & npm install --global @packages
        Assert-CommandSucceeded 'npm install --global'
    }
}

$pythonManifest = Join-Path $PackagesPath 'python.txt'
if ((Test-Path -LiteralPath $pythonManifest -PathType Leaf) -and @(Get-ManifestLines $pythonManifest).Count -gt 0) {
    if (-not (Get-Command python -ErrorAction SilentlyContinue)) { throw 'python.txt exists but Python is unavailable.' }
    $global:LASTEXITCODE = 0
    & python -m pip install -r $pythonManifest
    Assert-CommandSucceeded 'python -m pip install'
}
