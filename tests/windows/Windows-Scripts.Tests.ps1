$ErrorActionPreference = 'Stop'
$scripts = Join-Path $PSScriptRoot '..\..\scripts\windows'
. (Join-Path $scripts 'Common.ps1')
$temp = Join-Path ([System.IO.Path]::GetTempPath()) ("dotfiles-tests-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $temp | Out-Null

function Assert-Equal($Expected, $Actual, $Message) {
    if ($Expected -cne $Actual) { throw "$Message. Expected '$Expected', got '$Actual'." }
}

function Assert-Throws([scriptblock]$Action, $Message) {
    $threw = $false
    try { & $Action } catch { $threw = $true }
    if (-not $threw) { throw $Message }
}

try {
    Assert-Throws { Get-ProfileDirectory -Name '..\escape' -Create } 'Profile traversal was accepted'
    Assert-Throws { Get-ProfileDirectory -Name 'missing-profile-for-test' } 'Missing profile was accepted'

    $packages = Join-Path $temp 'packages'
    $global:Calls = @()
    function scoop {
        $global:Calls += "scoop $($args -join ' ')"
        $global:LASTEXITCODE = 0
        if ($args[0] -eq 'export') { return '{"apps":[{"Name":"git"}],"buckets":[{"Name":"main"}]}' }
    }
    function npm {
        $global:Calls += "npm $($args -join ' ')"
        $global:LASTEXITCODE = 0
        if ($args[0] -eq 'ls') { return '{"dependencies":{"typescript":{},"npm":{},"@scope/tool":{}}}' }
    }
    function python {
        $global:Calls += "python $($args -join ' ')"
        $global:LASTEXITCODE = 0
        if ($args[2] -eq 'freeze') { return 'requests==2.0' }
    }

    & (Join-Path $scripts 'Backup-Packages.ps1') $packages
    $scoopfile = Join-Path $packages 'scoopfile.json'
    $scoopData = Get-Content -LiteralPath $scoopfile -Raw | ConvertFrom-Json
    Assert-Equal 'git' $scoopData.apps[0].Name 'Scoop export was not saved as JSON'
    Assert-Equal "@scope/tool`ntypescript`n" ((Get-Content (Join-Path $packages 'npm.txt') -Raw) -replace "`r`n", "`n") 'npm packages were not exported'
    Assert-Equal "requests==2.0`n" ((Get-Content (Join-Path $packages 'python.txt') -Raw) -replace "`r`n", "`n") 'Python packages were not exported'

    & (Join-Path $scripts 'Install-Packages.ps1') $packages
    if ($global:Calls -notcontains "scoop import $scoopfile") { throw 'Scoopfile was not imported' }
    if ($global:Calls -notcontains 'npm install --global @scope/tool typescript') { throw 'npm packages were not installed' }
    if ($global:Calls -notcontains "python -m pip install -r $(Join-Path $packages 'python.txt')") { throw 'Python packages were not installed' }

    $before = Get-Content -LiteralPath $scoopfile -Raw
    function scoop { $global:LASTEXITCODE = 1; return 'broken export' }
    Assert-Throws { & (Join-Path $scripts 'Backup-Packages.ps1') $packages } 'Failed Scoop export was accepted'
    Assert-Equal $before (Get-Content -LiteralPath $scoopfile -Raw) 'Failed export changed the existing manifest'

    $legacy = Join-Path $temp 'legacy'
    New-Item -ItemType Directory -Path $legacy | Out-Null
    Set-Content -LiteralPath (Join-Path $legacy 'scoop.txt') -Value @('# old profile', 'git', '', '7zip')
    $global:Calls = @()
    function scoop { $global:Calls += "scoop $($args -join ' ')"; $global:LASTEXITCODE = 0 }
    & (Join-Path $scripts 'Install-Packages.ps1') $legacy
    Assert-Equal 'scoop install git,scoop install 7zip' ($global:Calls -join ',') 'Legacy Scoop list was not restored'

    $live = Join-Path $temp 'live.txt'
    $configs = Join-Path $temp 'configurations'
    $mapping = @(@{ Name = 'vimrc'; Destination = $live })
    Set-Content -LiteralPath $live -Value 'original'
    & (Join-Path $scripts 'Backup-Configurations.ps1') $configs $mapping
    Assert-Equal 'original' (Get-Content -LiteralPath (Join-Path $configs 'vimrc') -Raw).Trim() 'Configuration backup failed'
    Set-Content -LiteralPath (Join-Path $configs 'vimrc') -Value 'replacement'
    & (Join-Path $scripts 'Install-Configurations.ps1') $configs $mapping
    Assert-Equal 'original' (Get-Content -LiteralPath "$live.pre-dotfiles.bak" -Raw).Trim() 'Original configuration was not preserved'
    Assert-Equal 'replacement' (Get-Content -LiteralPath $live -Raw).Trim() 'Configuration was not installed'
    & (Join-Path $scripts 'Install-Configurations.ps1') $configs $mapping
    Set-Content -LiteralPath (Join-Path $configs 'vimrc') -Value 'third version'
    Assert-Throws { & (Join-Path $scripts 'Install-Configurations.ps1') $configs $mapping } 'Existing backup was overwritten'

    Write-Output 'Windows script regression checks passed.'
} finally {
    Remove-Item -LiteralPath $temp -Recurse -Force
}
