$repoPath = "$PSScriptRoot\..\.."
$backupPath = Get-Content "$repoPath\data\config\windows-backup-path.txt"

if ([string]::IsNullOrEmpty($backupPath)) {
    $backupPath = "$repoPath\data\backup"
}

$backupPath = $backupPath.Trim()

& "$PSScriptRoot\Backup-Packages.ps1" $backupPath
& "$PSScriptRoot\Backup-WindowsKey.ps1" $backupPath
# TODO: Check if Putty is installed.
& "$PSScriptRoot\Backup-Putty.ps1" $backupPath
