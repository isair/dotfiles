param([string]$backupPath="")

if ([string]::IsNullOrEmpty($backupPath)) {
    Write-Error "Backup path must be provided as the first argument."
    Exit-PSHostProcess
}

$backupPath = $backupPath.Trim()

regedit /e "$backupPath\putty.reg" HKEY_CURRENT_USER\Software\SimonTatham
