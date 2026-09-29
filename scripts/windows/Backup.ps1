param([string]$ProfileName = 'personal', [switch]$Gist)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Common.ps1"

$profilePath = Get-ProfileDirectory -Name $ProfileName -Create
& "$PSScriptRoot\Backup-Packages.ps1" (Join-Path $profilePath 'packages')
& "$PSScriptRoot\Backup-Configurations.ps1" (Join-Path $profilePath 'configurations')

Write-Output "Backed up profile '$ProfileName' to $profilePath"

if ($Gist) {
    if (Get-Command py -ErrorAction SilentlyContinue) {
        & py -3 "$PSScriptRoot\..\gist.py" backup $ProfileName
    } elseif (Get-Command python -ErrorAction SilentlyContinue) {
        & python "$PSScriptRoot\..\gist.py" backup $ProfileName
    } else {
        throw 'Python 3 is required to create a gist backup.'
    }
    Assert-CommandSucceeded 'gist backup'
}
