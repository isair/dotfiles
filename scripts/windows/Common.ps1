$script:WindowsScriptsRoot = $PSScriptRoot

function Get-ProfileDirectory {
    param([string]$Name = 'personal', [switch]$Create, [string]$ProfilesRoot = (Join-Path $script:WindowsScriptsRoot '..\..\profiles'))

    if ([string]::IsNullOrWhiteSpace($Name)) { $Name = 'personal' }
    if ($Name -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$' -or $Name -eq '.' -or $Name -eq '..') {
        throw "Invalid profile name: $Name"
    }

    $path = Join-Path $ProfilesRoot $Name
    if ($Create) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    } elseif (-not (Test-Path -LiteralPath $path -PathType Container)) {
        throw "Profile '$Name' does not exist. Run Backup.ps1 first or choose an existing profile."
    }
    return (Resolve-Path -LiteralPath $path).Path
}

function Get-ProfileChain {
    param([string]$Name = 'personal', [string]$ProfilesRoot = (Join-Path $script:WindowsScriptsRoot '..\..\profiles'))

    $chain = New-Object System.Collections.ArrayList
    $visiting = New-Object System.Collections.ArrayList
    Add-ProfileToChain -Name $Name -ProfilesRoot $ProfilesRoot -Chain $chain -Visiting $visiting
    return $chain.ToArray()
}

function Add-ProfileToChain {
    param([string]$Name, [string]$ProfilesRoot, [System.Collections.ArrayList]$Chain, [System.Collections.ArrayList]$Visiting)

    $path = Get-ProfileDirectory -Name $Name -ProfilesRoot $ProfilesRoot
    if ($Visiting.Contains($Name)) { throw "Profile inheritance cycle at $Name" }
    if ($Chain.Contains($path)) { return }
    $Visiting.Add($Name) | Out-Null
    $inherits = Join-Path $path 'inherits'
    if (Test-Path -LiteralPath $inherits -PathType Leaf) {
        foreach ($line in Get-Content -LiteralPath $inherits -Encoding UTF8) {
            $parent = ($line -replace '#.*$', '').Trim()
            if ($parent) {
                Add-ProfileToChain -Name $parent -ProfilesRoot $ProfilesRoot -Chain $Chain -Visiting $Visiting
            }
        }
    }
    $Visiting.RemoveAt($Visiting.Count - 1)
    $Chain.Add($path) | Out-Null
}

function Assert-CommandSucceeded {
    param([string]$Command)
    if ($global:LASTEXITCODE -ne 0) { throw "$Command failed with exit code $global:LASTEXITCODE" }
}

function Write-Manifest {
    param([string]$Path, [string]$Content)
    $tempPath = "$Path.tmp"
    try {
        [System.IO.File]::WriteAllText($tempPath, $Content, (New-Object System.Text.UTF8Encoding($false)))
        Move-Item -LiteralPath $tempPath -Destination $Path -Force
    } finally {
        if (Test-Path -LiteralPath $tempPath) { Remove-Item -LiteralPath $tempPath -Force }
    }
}

function Get-ManifestLines {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { return }
    Get-Content -LiteralPath $Path -Encoding UTF8 | ForEach-Object { $_.Trim() } |
        Where-Object { $_ -and -not $_.StartsWith('#') }
}

function Remove-InheritedProfileContent {
    param([string[]]$ProfileChain)

    if ($ProfileChain.Count -lt 2) { return }
    $child = $ProfileChain[-1]
    $parents = @($ProfileChain[0..($ProfileChain.Count - 2)])
    foreach ($name in @('npm.txt', 'python.txt')) {
        $manifest = Join-Path (Join-Path $child 'packages') $name
        if (-not (Test-Path -LiteralPath $manifest -PathType Leaf)) { continue }
        $inherited = @($parents | ForEach-Object { Get-ManifestLines (Join-Path (Join-Path $_ 'packages') $name) })
        $remaining = @(Get-ManifestLines $manifest | Where-Object { $_ -notin $inherited })
        $content = if ($remaining.Count) { ($remaining -join "`n") + "`n" } else { '' }
        Write-Manifest $manifest $content
    }

    $scoopfile = Join-Path (Join-Path $child 'packages') 'scoopfile.json'
    if (Test-Path -LiteralPath $scoopfile -PathType Leaf) {
        $manifest = Get-Content -LiteralPath $scoopfile -Raw -Encoding UTF8 | ConvertFrom-Json
        $parentApps = @()
        $parentBuckets = @()
        foreach ($parent in $parents) {
            $parentScoopfile = Join-Path (Join-Path $parent 'packages') 'scoopfile.json'
            if (-not (Test-Path -LiteralPath $parentScoopfile -PathType Leaf)) { continue }
            $parentManifest = Get-Content -LiteralPath $parentScoopfile -Raw -Encoding UTF8 | ConvertFrom-Json
            $parentApps += @($parentManifest.apps | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 20 })
            $parentBuckets += @($parentManifest.buckets | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 20 })
        }
        $manifest.apps = @($manifest.apps | Where-Object { ($_ | ConvertTo-Json -Compress -Depth 20) -notin $parentApps })
        # Scoop import resolves app sources against buckets in the same file.
        $requiredBuckets = @($manifest.apps | ForEach-Object { $_.Source })
        $manifest.buckets = @($manifest.buckets | Where-Object {
            ($_ | ConvertTo-Json -Compress -Depth 20) -notin $parentBuckets -or $_.Name -in $requiredBuckets
        })
        if ($manifest.apps.Count -eq 0 -and $manifest.buckets.Count -eq 0) {
            Remove-Item -LiteralPath $scoopfile
        } else {
            Write-Manifest $scoopfile ($manifest | ConvertTo-Json -Depth 20)
        }
    }

    foreach ($name in @('powershell-windows.ps1', 'powershell.ps1', 'vimrc', 'ssh_config', 'hyper.js')) {
        $childConfig = Join-Path (Join-Path $child 'configurations') $name
        if (-not (Test-Path -LiteralPath $childConfig -PathType Leaf)) { continue }
        $inheritedConfig = $null
        foreach ($parent in $parents) {
            $candidate = Join-Path (Join-Path $parent 'configurations') $name
            if (Test-Path -LiteralPath $candidate -PathType Leaf) { $inheritedConfig = $candidate }
        }
        if ($inheritedConfig) {
            $current = [System.IO.File]::ReadAllBytes($childConfig)
            $inherited = [System.IO.File]::ReadAllBytes($inheritedConfig)
            if ([Convert]::ToBase64String($current) -eq [Convert]::ToBase64String($inherited)) {
                Remove-Item -LiteralPath $childConfig
            }
        }
    }
}

function Get-ConfigurationMappings {
    $documents = [Environment]::GetFolderPath('MyDocuments')
    if (-not $documents) { throw 'Cannot resolve the Documents folder.' }

    @(
        @{ Name = 'powershell-windows.ps1'; Destination = (Join-Path $documents 'WindowsPowerShell\Microsoft.PowerShell_profile.ps1') },
        @{ Name = 'powershell.ps1'; Destination = (Join-Path $documents 'PowerShell\Microsoft.PowerShell_profile.ps1') },
        @{ Name = 'vimrc'; Destination = (Join-Path $HOME '_vimrc') },
        @{ Name = 'ssh_config'; Destination = (Join-Path $HOME '.ssh\config') },
        @{ Name = 'hyper.js'; Destination = (Join-Path ([Environment]::GetFolderPath('ApplicationData')) 'Hyper\.hyper.js') }
    )
}
