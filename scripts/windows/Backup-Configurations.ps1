param([Parameter(Mandatory=$true)][string]$BackupPath, [object[]]$Mappings)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Common.ps1"
New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null

if ($null -eq $Mappings) { $Mappings = @(Get-ConfigurationMappings) }
foreach ($mapping in $Mappings) {
    if (Test-Path -LiteralPath $mapping.Destination -PathType Leaf) {
        Copy-Item -LiteralPath $mapping.Destination -Destination (Join-Path $BackupPath $mapping.Name) -Force
    }
}
