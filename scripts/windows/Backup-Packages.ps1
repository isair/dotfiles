param([Parameter(Mandatory=$true)][string]$BackupPath)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Common.ps1"
New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    $global:LASTEXITCODE = 0
    $export = (& scoop export) -join [Environment]::NewLine
    Assert-CommandSucceeded 'scoop export'
    $parsed = $export | ConvertFrom-Json -ErrorAction Stop
    if ($null -eq $parsed.apps -or $null -eq $parsed.buckets) {
        throw 'scoop export did not return a Scoopfile with apps and buckets.'
    }
    Write-Manifest (Join-Path $BackupPath 'scoopfile.json') $export
} else {
    Write-Warning 'Scoop was not found; existing Scoop backup was left untouched.'
}

if (Get-Command npm -ErrorAction SilentlyContinue) {
    $global:LASTEXITCODE = 0
    $output = (& npm ls --global --json --depth=0) -join [Environment]::NewLine
    Assert-CommandSucceeded 'npm ls --global'
    $installed = $output | ConvertFrom-Json -ErrorAction Stop
    $names = @($installed.dependencies.PSObject.Properties.Name | Where-Object { $_ -ne 'npm' } | Sort-Object -Unique)
    Write-Manifest (Join-Path $BackupPath 'npm.txt') (($names -join "`n") + "`n")
} else {
    Write-Warning 'npm was not found; existing npm backup was left untouched.'
}

if (Get-Command python -ErrorAction SilentlyContinue) {
    $global:LASTEXITCODE = 0
    $requirements = (& python -m pip freeze) -join "`n"
    Assert-CommandSucceeded 'python -m pip freeze'
    Write-Manifest (Join-Path $BackupPath 'python.txt') ($requirements + "`n")
} else {
    Write-Warning 'Python was not found; existing Python backup was left untouched.'
}
