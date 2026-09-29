param([string]$ProfileName = 'personal')

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Common.ps1"

$profilePath = Get-ProfileDirectory -Name $ProfileName -Create
$profileChain = @(Get-ProfileChain -Name $ProfileName)
& "$PSScriptRoot\Backup-Packages.ps1" (Join-Path $profilePath 'packages')
& "$PSScriptRoot\Backup-Configurations.ps1" (Join-Path $profilePath 'configurations')
Remove-InheritedProfileContent -ProfileChain $profileChain

Write-Output "Backed up profile '$ProfileName' to $profilePath"
