param([Parameter(Mandatory=$true)][string]$ConfigurationsPath, [object[]]$Mappings)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Common.ps1"

if ($null -eq $Mappings) { $Mappings = @(Get-ConfigurationMappings) }
foreach ($mapping in $Mappings) {
    $source = Join-Path $ConfigurationsPath $mapping.Name
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { continue }
    $parent = Split-Path -Parent $mapping.Destination
    New-Item -ItemType Directory -Path $parent -Force | Out-Null

    if (Test-Path -LiteralPath $mapping.Destination) {
        $current = [System.IO.File]::ReadAllBytes($mapping.Destination)
        $desired = [System.IO.File]::ReadAllBytes($source)
        if ([Convert]::ToBase64String($current) -eq [Convert]::ToBase64String($desired)) { continue }
        $saved = "$($mapping.Destination).pre-dotfiles.bak"
        if (Test-Path -LiteralPath $saved) {
            throw "Cannot replace $($mapping.Destination): backup already exists at $saved"
        }
        Copy-Item -LiteralPath $mapping.Destination -Destination $saved
    }
    Copy-Item -LiteralPath $source -Destination $mapping.Destination -Force
}
