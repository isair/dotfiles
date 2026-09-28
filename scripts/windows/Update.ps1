$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Common.ps1"

$repoPath = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
if (Get-Command git -ErrorAction SilentlyContinue) {
    $global:LASTEXITCODE = 0
    $changes = & git -C $repoPath status --porcelain
    Assert-CommandSucceeded 'git status'
    if ($changes) {
        Write-Warning 'Repository has local changes; skipping git pull.'
    } else {
        $global:LASTEXITCODE = 0
        & git -C $repoPath pull --ff-only
        Assert-CommandSucceeded 'git pull'
    }
}

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    $global:LASTEXITCODE = 0
    & scoop update
    Assert-CommandSucceeded 'scoop update'
    $global:LASTEXITCODE = 0
    & scoop update '*'
    Assert-CommandSucceeded 'scoop update *'
}
