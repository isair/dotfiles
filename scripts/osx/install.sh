#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1

if ! hash xcode-select 2>/dev/null; then
  echo Xcode needs to be installed
  exit
fi

## Install command line tools
xcode-select -p
if [[ $? -ne 0 ]]; then
  xcode-select --install
fi

## Make sure everthing is up-to-date
sudo softwareupdate -i -a

## Link airport binary
if ! hash airport 2>/dev/null; then
  sudo ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/local/bin/airport
fi

## Install Oh My Zsh
if ! hash zsh 2>/dev/null; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

## Install Homebrew
if ! hash brew 2>/dev/null; then
  rm -rf "/usr/local/Cellar" "/usr/local/.git"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

## Make sure brew cask has access to older versions of packages.
brew tap caskroom/versions

## Make sure packages and their definitions are up-to-date
brew update
brew upgrade

## Install git
brew install openssl
brew install curl
brew install git --with-curl --with-openssl
brew install hub
brew install git-lfs && git lfs install

# Configure git
git config --global core.autocrlf input

## Install nvm and node
if ! hash nvm 2>/dev/null; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.26.1/install.sh | bash
  source ~/.nvm/nvm.sh
  nvm install node
  nvm alias default node
fi

## Install rbenv, ruby-builder, ruby and bundler
if ! hash rbenv 2>/dev/null; then
  brew install rbenv
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  latest_stable_ruby=$(rbenv install -l | grep -v - | tail -1)
  rbenv install $latest_stable_ruby
  rbenv global $latest_stable_ruby
fi

if ! hash bundler 2>/dev/null; then
  gem install bundler
  rbenv rehash
fi

## Install Java
brew cask install java
brew cask install java8

## Install Android SDK
brew cask install android-sdk

## Install essential packages
brew install coreutils
brew install vim
brew install watchman
brew install youtube-dl
brew install imagemagick
brew install xaric
brew install mkcert
brew install nss

## Install apps for servers, vms, and normal installations
brew cask install visual-studio-code
brew cask install gitup
brew cask install the-unarchiver
brew cask install cd-to
brew cask install charles
brew cask install disk-inventory-x

# Install apps for vms and normal installations
if [ "$1" != "--server" ]; then
  brew cask install bettertouchtool
  brew cask install imageoptim
  # brew cask install desktime
  # brew cask install fabric # doesn't exist
fi

# Install apps for normal installations only
if [ "$1" != "--vm" -a "$1" != "--server" ]; then
  brew cask install keepassxc
  brew cask install filezilla
  brew cask install jdownloader
  brew cask install franz # for personal messaging
  brew cask install station # for work accounts & messaging
  brew cask install vlc
  brew cask install spotify
  brew cask install torbrowser
  brew cask install android-studio
  brew cask install steam
  brew cask install gog-galaxy
  brew cask install openemu    # TODO: Script for backing up ROMs and save files.
  # paid apps after this line
  brew cask install dash
  brew cask install daisydisk
  brew cask install boom
  # paid but not available on cask after this line
  # brew cask install atext
  # brew cask install omnigraffle
  # brew cask install bartender2
  # brew cask install hopper
  # brew cask install photosweeper-X
  # brew cask install sketch
  # brew cask install transmit
fi

## Install maintenance apps
brew cask install malwarebytes
brew cask install appcleaner
brew cask install onyx

## Python and Python packages
brew install python
if [ "$1" != "--server" ]; then
  pip install -U subliminal
fi

## Install security packages and apps
# brew install otx
brew install gdb
brew install reaver
brew install aircrack-ng
brew install nmap
brew install theharvester
brew cask install bit-slicer

## Install essential node packages
npm i -g yarn
npm i -g npm-which
npm i -g devtool
npm i -g http-server
if [ "$1" != "--server" ]; then
  npm i -g react-native-cli
fi

## Install QuickLook plugins
# Source: https://github.com/sindresorhus/quick-look-plugins
# brew cask install betterzipql # doesn't exist anymore
# brew cask install cert-quicklook # doesn't exist anymore
brew cask install epubquicklook
brew cask install qlcolorcode
brew cask install qlmarkdown
brew cask install qlprettypatch
brew cask install qlstephen
brew cask install quicklook-csv
brew cask install quicklook-json
brew cask install suspicious-package
# brew cask install webp-quicklook # doesn't exist anymore
qlmanage -r

## Clean things up
"$PWD/cleanup.sh"

## Symlink dotfiles
"$PWD/../unix/symlink-dotfiles.sh"
