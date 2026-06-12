param([string]$backupPath="")

if ([string]::IsNullOrEmpty($backupPath)) {
    Write-Error "Backup path must be provided as the first argument."
    exit 1
}

$backupPath = $backupPath.Trim()

# Ensure the backup directory exists before writing into it.
New-Item -ItemType Directory -Force -Path $backupPath | Out-Null

scoop export | ForEach-Object {
    $packageData = $_ -split "\s+"
    $packageName = $packageData[0]
    return $packageName
} | Out-File "$backupPath\scoop.txt" -Encoding UTF8

Write-Output "Successfully backed up packages under $backupPath"
