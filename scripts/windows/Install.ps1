param([string]$ProfileName = 'personal')

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Common.ps1"

$profileChain = @(Get-ProfileChain -Name $ProfileName)
foreach ($profilePath in $profileChain) {
    & "$PSScriptRoot\Install-Packages.ps1" (Join-Path $profilePath 'packages')
}
$configurations = @($profileChain | ForEach-Object { Join-Path $_ 'configurations' })
& "$PSScriptRoot\Install-Configurations.ps1" $configurations

if (Get-Command git -ErrorAction SilentlyContinue) {
    & git config --global core.autocrlf true
    Assert-CommandSucceeded 'git config'
}
Write-Output "Installed profile '$ProfileName'"
