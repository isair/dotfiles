# This script needs to be run as an administrator

Set-ExecutionPolicy RemoteSigned

## Install package manager
Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

## Install git
choco install openssh -y
choco install git -y
choco install git-lfs -y
# TODO: Write .gitconfig

## Install nvm, node, and yarn
choco install nvm -y
refreshenv
nvm install latest
choco install yarn -y
refreshenv

## Install essential apps
choco install GoogleChrome -y
choco install googledrive -y
choco install spotify -y
choco install vmware-workstation-player -y
choco install VisualStudioCode -y
choco install GitHub -y
choco install putty.install -y
choco install filezilla -y
choco install seer -y
choco install autohotkey.install -y
choco install gpmdp -y
choco install crashplan -y
# TODO: Add these when they install successfully through chocolatey: 7zip, turbotop, teamviewer, skype,
# microsoft teams, logitech gaming software, desktime, blizzard app, steam, nvidia gefore experience,
# razer cortex, ps4 remote play

# TODO: Clone and run vmware player unlocker

## Run AHK scripts at startup
.\make-shortcut keyboard-shortcuts.ahk "$Home\AppData\Roaming\Microsoft\Windows\Start Menu\keyboard-shortcuts.lnk"

## Install essential node packages
yarn global add create-react-native-app
