param([string]$backupPath="")

if ([string]::IsNullOrEmpty($backupPath)) {
    Write-Error "Backup path must be provided as the first argument."
    exit 1
}

# Ensure the backup directory exists before copying into it.
New-Item -ItemType Directory -Force -Path $backupPath | Out-Null

# TODO: Get active documents path.
Copy-Item ~\OneDrive\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 $backupPath
Copy-Item ~\AppData\Roaming\Hyper\.hyper.js "$backupPath\hyper-windows.js"