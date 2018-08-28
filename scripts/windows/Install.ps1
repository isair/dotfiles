# This script needs to be run as an administrator

## Construct paths
$repoPath = "$PSScriptRoot\..\.."
$backupPath = Get-Content "$repoPath\data\config\windows-backup-path.txt"

## Allow scripts to be executed
Set-ExecutionPolicy RemoteSigned

## Install package manager
Invoke-Expression (new-object net.webclient).downloadstring('https://get.scoop.sh')

## Add package sources
# TODO: Add scripts for backing up and restoring sources
scoop bucket add extras
scoop bucket add java
scoop bucket add nonportable
scoop bucket add versions

## Install packages
& "$PSScriptRoot\Install-Packages.ps1" $backupPath

## Configure git
git config --global core.autocrlf true
# TODO: Write .gitconfig

## Install the latest node release
nvm install latest

## Run AHK scripts at startup
& "$PSScriptRoot\Make-Shortcut.ps1" keyboard-shortcuts.ahk "C:\Users\$env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\keyboard-shortcuts.lnk"

## Install essential node packages
yarn global add react-native-cli
