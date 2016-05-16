#!/usr/bin/env bash

# TO-DO: Install Xcode

## Install command line tools
xcode-select -p
if [[ $? -ne 0 ]]; then
  xcode-select --install
else
  echo Xcode needs to be installed
  exit 1
fi

## Make sure everthing is up-to-date
sudo softwareupdate -i -a

## Link airport binary
if ! hash airport 2>/dev/null; then
  sudo ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/local/bin/airport
fi

## Install Oh My Zsh
if ! hash zsh 2>/dev/null; then
  sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

## Install Homebrew
if ! hash brew 2>/dev/null; then
  rm -rf "/usr/local/Cellar" "/usr/local/.git"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

## Make sure packages and package definitions are up-to-date
brew update
brew upgrade

## Install brew cask
brew tap caskroom/cask
brew install brew-cask

## Install essential packages
brew install coreutils
brew install thefuck
brew install vim
brew install git
brew install hub
brew install git-lfs && git lfs install
brew install watchman
brew install youtube-dl
brew install imagemagick
brew install lynx
brew install tree
brew install xaric

## Install essential apps
brew cask install lastpass
brew cask install google-chrome
brew cask install macvim
# brew cask install desktime
brew cask install atom
brew cask install bettertouchtool
brew cask install gitup
brew cask install slack
brew cask install discord
brew cask install the-unarchiver
brew cask install flux
brew cask install teamviewer
brew cask install dropbox
brew cask install google-drive
brew cask install fabric
brew cask install goofy
brew cask install vlc
brew cask install spotify
brew cask install skype
brew cask install torbrowser
brew cask install imageoptim
brew cask install cd-to
brew cask install gfxcardstatus
brew cask install jdownloader
brew cask install steam
brew cask install gog-galaxy
brew cask install openemu    # TODO: Script for backing up ROMs and save files.
brew cask install onyx
brew cask install macupdate-desktop
brew cask install filezilla
# Paid
# brew cask install atext
brew cask install dash
# brew cask install omnigraffle
brew cask install daisydisk
brew cask install boom
# brew cask install bartender2
# brew cask install hopper
# brew cask install photosweeper-X
brew cask install sketch
# brew cask install transmit

## Install maintenance apps
brew cask install malwarebytes-anti-malware
brew cask install ccleaner
brew cask install appcleaner

## Install essential python packages
sudo pip install -U subliminal

## Install atom packages
apm install vim-mode
apm install merge-conflicts
apm install git-plus

## Install mobile development packages and apps
sudo gem install cocoapods
sudo gem install gym
sudo gem install fastlane
brew install xctool
brew install android-sdk
brew cask install android-studio
brew cask install genymotion

## Install security packages and apps
# brew install otx
brew install gdb
brew install reaver
brew install aircrack-ng
brew install nmap
brew install theharvester
brew cask install bit-slicer

## Install nvm and the latest version of node
if ! hash nvm 2>/dev/null; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.26.1/install.sh | bash
  nvm install node
  nvm alias default node
fi

## Install essential node packages
npm i -g npm-which
npm i -g devtool
npm i -g http-server
npm i -g react-native-cli
npm i -g eslint
npm i -g eslint-plugin-react
npm i -g eslint-config-airbnb
npm i -g babel-eslint
npm i -g flow-bin

## Install QuickLook plugins
# Source: https://github.com/sindresorhus/quick-look-plugins
brew cask install betterzipql
brew cask install cert-quicklook
brew cask install epubquicklook
brew cask install qlcolorcode
brew cask install qlmarkdown
brew cask install qlprettypatch
brew cask install qlstephen
brew cask install quicklook-csv
brew cask install quicklook-json
brew cask install suspicious-package
brew cask install webp-quicklook
qlmanage -r

## Clean things up
brew linkapps
brew cleanup
brew prune
brew cask cleanup
gem cleanup
