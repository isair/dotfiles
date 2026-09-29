$script:WindowsScriptsRoot = $PSScriptRoot

function Get-ProfileDirectory {
    param([string]$Name = 'personal', [switch]$Create)

    if ([string]::IsNullOrWhiteSpace($Name)) { $Name = 'personal' }
    if ($Name -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$' -or $Name -eq '.' -or $Name -eq '..') {
        throw "Invalid profile name: $Name"
    }

    $path = Join-Path (Join-Path $script:WindowsScriptsRoot '..\..\profiles') $Name
    if ($Create) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    } elseif (-not (Test-Path -LiteralPath $path -PathType Container)) {
        throw "Profile '$Name' does not exist. Run Backup.ps1 first or choose an existing profile."
    }
    return (Resolve-Path -LiteralPath $path).Path
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
