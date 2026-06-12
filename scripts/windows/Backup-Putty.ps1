param([string]$backupPath="")

if ([string]::IsNullOrEmpty($backupPath)) {
    Write-Error "Backup path must be provided as the first argument."
    exit 1
}

$backupPath = $backupPath.Trim()

# Ensure the backup directory exists before writing into it.
New-Item -ItemType Directory -Force -Path $backupPath | Out-Null

regedit /e "$backupPath\putty.reg" HKEY_CURRENT_USER\Software\SimonTatham
