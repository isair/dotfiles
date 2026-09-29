$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\Common.ps1"

if (Get-Command scoop -ErrorAction SilentlyContinue) {
    $global:LASTEXITCODE = 0
    & scoop cleanup '*'
    Assert-CommandSucceeded 'scoop cleanup *'
    $global:LASTEXITCODE = 0
    & scoop cache rm '*'
    Assert-CommandSucceeded 'scoop cache rm *'
}
