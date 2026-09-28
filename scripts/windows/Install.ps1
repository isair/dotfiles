param([string]$ProfileName = 'personal')

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Common.ps1"

$profilePath = Get-ProfileDirectory -Name $ProfileName
& "$PSScriptRoot\Install-Packages.ps1" (Join-Path $profilePath 'packages')
& "$PSScriptRoot\Install-Configurations.ps1" (Join-Path $profilePath 'configurations')

if (Get-Command git -ErrorAction SilentlyContinue) {
    & git config --global core.autocrlf true
    Assert-CommandSucceeded 'git config'
}
Write-Output "Installed profile '$ProfileName'"
