param([string]$backupPath="")

if ([string]::IsNullOrEmpty($backupPath)) {
    Write-Error "Backup path must be provided as the first argument."
    Exit-PSHostProcess
}

# TODO: Get active documents path.
Copy-Item ~\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 $backupPath
Copy-Item ~\AppData\Roaming\Hyper\.hyper.js "$backupPath\hyper-windows.js"