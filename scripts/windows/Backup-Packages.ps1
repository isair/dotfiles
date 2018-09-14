param([string]$backupPath="")

if ([string]::IsNullOrEmpty($backupPath)) {
    Write-Error "Backup path must be provided as the first argument."
    Exit-PSHostProcess
}

$backupPath = $backupPath.Trim()

scoop export | ForEach-Object {
    $packageData = $_ -split "\s+"
    $packageName = $packageData[0]
    return $packageName
} | Out-File "$backupPath\scoop-packages.txt" -Encoding UTF8

Write-Output "Successfully backed up packages under $backupPath"
