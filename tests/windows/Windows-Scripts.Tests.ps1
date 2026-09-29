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

    $profilesRoot = Join-Path $temp 'profiles'
    $baseProfile = Get-ProfileDirectory -Name 'base' -ProfilesRoot $profilesRoot -Create
    $childProfile = Get-ProfileDirectory -Name 'child' -ProfilesRoot $profilesRoot -Create
    foreach ($path in @($baseProfile, $childProfile)) {
        New-Item -ItemType Directory -Path (Join-Path $path 'packages') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $path 'configurations') -Force | Out-Null
    }
    Set-Content -LiteralPath (Join-Path $childProfile 'inherits') -Value 'base'
    $chain = @(Get-ProfileChain -Name 'child' -ProfilesRoot $profilesRoot)
    Assert-Equal "$baseProfile,$childProfile" ($chain -join ',') 'Profile order was wrong'
    Set-Content -LiteralPath (Join-Path $baseProfile 'packages\npm.txt') -Value 'typescript'
    Set-Content -LiteralPath (Join-Path $childProfile 'packages\npm.txt') -Value @('typescript', '@scope/tool')
    Set-Content -LiteralPath (Join-Path $baseProfile 'packages\scoopfile.json') -Value '{"apps":[{"Name":"git"}],"buckets":[{"Name":"main"}]}'
    Set-Content -LiteralPath (Join-Path $childProfile 'packages\scoopfile.json') -Value '{"apps":[{"Name":"git"},{"Name":"7zip","Source":"main"}],"buckets":[{"Name":"main"}]}'
    Set-Content -LiteralPath (Join-Path $baseProfile 'configurations\vimrc') -Value 'shared'
    Set-Content -LiteralPath (Join-Path $childProfile 'configurations\vimrc') -Value 'shared'
    Remove-InheritedProfileContent -ProfileChain $chain
    Assert-Equal '@scope/tool' ((Get-Content -LiteralPath (Join-Path $childProfile 'packages\npm.txt') -Raw).Trim()) 'Inherited npm package was backed up twice'
    $childScoop = Get-Content -LiteralPath (Join-Path $childProfile 'packages\scoopfile.json') -Raw | ConvertFrom-Json
    Assert-Equal '7zip' $childScoop.apps[0].Name 'Inherited Scoop app was backed up twice'
    Assert-Equal 'main' $childScoop.buckets[0].Name 'Bucket required by child app was removed'
    if (Test-Path -LiteralPath (Join-Path $childProfile 'configurations\vimrc')) { throw 'Inherited configuration was backed up twice' }
    Set-Content -LiteralPath (Join-Path $childProfile 'configurations\vimrc') -Value 'child'
    $selected = Join-Path $temp 'selected-vimrc'
    & (Join-Path $scripts 'Install-Configurations.ps1') @(
        (Join-Path $baseProfile 'configurations'), (Join-Path $childProfile 'configurations')
    ) @(@{ Name = 'vimrc'; Destination = $selected })
    Assert-Equal 'child' ((Get-Content -LiteralPath $selected -Raw).Trim()) 'Child configuration did not win'
    Set-Content -LiteralPath (Join-Path $baseProfile 'inherits') -Value 'child'
    Assert-Throws { Get-ProfileChain -Name 'child' -ProfilesRoot $profilesRoot } 'Profile cycle was accepted'
    Set-Content -LiteralPath (Join-Path $baseProfile 'inherits') -Value 'missing'
    Assert-Throws { Get-ProfileChain -Name 'child' -ProfilesRoot $profilesRoot } 'Missing parent was accepted'
    Set-Content -LiteralPath (Join-Path $baseProfile 'inherits') -Value '../escape'
    Assert-Throws { Get-ProfileChain -Name 'child' -ProfilesRoot $profilesRoot } 'Invalid parent was accepted'

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

    $global:Calls = @()
    function git {
        $global:Calls += "git $($args -join ' ')"
        $global:LASTEXITCODE = 0
        if ($args -contains 'status') { return '' }
    }
    function scoop { $global:Calls += "scoop $($args -join ' ')"; $global:LASTEXITCODE = 0 }
    & (Join-Path $scripts 'Update.ps1')
    if (-not ($global:Calls | Where-Object { $_ -match '^git .* pull --ff-only$' })) { throw 'Clean repo was not updated' }
    if ($global:Calls -notcontains 'scoop update *') { throw 'Scoop apps were not updated' }

    $global:Calls = @()
    function git {
        $global:Calls += "git $($args -join ' ')"
        $global:LASTEXITCODE = 0
        if ($args -contains 'status') { return ' M local-change' }
    }
    & (Join-Path $scripts 'Update.ps1') 3>$null
    if ($global:Calls | Where-Object { $_ -match '^git .* pull --ff-only$' }) { throw 'Dirty repo was pulled' }

    $global:Calls = @()
    & (Join-Path $scripts 'Cleanup.ps1')
    Assert-Equal 'scoop cleanup *,scoop cache rm *' ($global:Calls -join ',') 'Scoop cleanup was not run'

    Write-Output 'Windows script regression checks passed.'
} finally {
    Remove-Item -LiteralPath $temp -Recurse -Force
}
