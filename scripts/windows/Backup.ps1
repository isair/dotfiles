param([string]$profileName="")

if ([string]::IsNullOrEmpty($profileName)) {
    $profileName = "personal"
}

$repoPath = "$PSScriptRoot\..\.."
$backupPath = "$repoPath\profiles\$profileName"
$backupPath = $backupPath.Trim()

& "$PSScriptRoot\Backup-Configurations.ps1" "$backupPath\configurations"
& "$PSScriptRoot\Backup-Packages.ps1" "$backupPath\packages"
& "$PSScriptRoot\Backup-WindowsKey.ps1" "$backupPath\secure\licenses"
# TODO: Check if Putty is installed.
& "$PSScriptRoot\Backup-Putty.ps1" "$backupPath\secure\connections"
