param([String]$backupPath="C:\Users\$env:USERNAME\Backup")

$packages = Get-Content "$backupPath/scoop-packages.txt"
scoop install @packages
