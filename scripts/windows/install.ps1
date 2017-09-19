# This script needs to be run as an administrator

Set-ExecutionPolicy RemoteSigned

## Install package manager
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

## Install packages via Chocolatey
choco install .\config\chocolatey-packages.config -y
refreshenv

# TODO: Write .gitconfig

## Install the latest node release
nvm install latest

## Install essential apps
choco install GoogleChrome -y
choco install googledrive -y
choco install vmware-workstation-player -y
choco install seer -y
# TODO: Add these when they install successfully through chocolatey: turbotop, microsoft teams, logitech gaming software, desktime, blizzard app, steam, nvidia gefore experience, razer cortex, ps4 remote play

# TODO: Clone and run vmware player unlocker

## Run AHK scripts at startup
.\make-shortcut keyboard-shortcuts.ahk "$Home\AppData\Roaming\Microsoft\Windows\Start Menu\keyboard-shortcuts.lnk"

## Install essential node packages
yarn global add create-react-native-app
