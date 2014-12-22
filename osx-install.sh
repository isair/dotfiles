#!/usr/bin/env bash

# Make sure Xcode is install before running

# Install command line tools
xcode-select -p
if [[ $? -ne 0 ]]; then
    xcode-select --install
fi

# Update all OSX packages
sudo softwareupdate -i -a

# Install Homebrew if not found
brew --version
if [[ $? -ne 0 ]]; then
    # Clean-up failed Homebrew install
    rm -rf "/usr/local/Cellar" "/usr/local/.git"
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew update
brew upgrade

# Include duplicates packages
brew tap homebrew/dupes

# Install Cask
brew tap caskroom/cask
brew install brew-cask

# Enhance core OS X
brew cask install xquartz

brew install bash
brew install ruby
brew install python

# Install essential apps
# brew cask install atext
brew cask install apptrap
brew cask install google-chrome
brew cask install lastpass-universal
# brew install xmarks-safari
brew cask install flux
brew cask install dropbox
brew cask install google-drive
brew cask install vlc
brew cask install spotify
brew cask install skype
brew cask install rowanj-gitx
brew cask install torbrowser
brew cask install imageoptim
brew cask install cd-to
brew cask install gfxcardstatus
brew cask install jdownloader
brew cask install subtitles
brew cask install steam
brew cask install playonmac  # TODO: Script for backing up drives.
brew cask install openemu    # TODO: Script for backing up ROMs and save files.
brew cask install bit-slicer
brew cask install onyx
brew cask install cleanmymac

# Install QuickLook plugins
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

# Clean things up
brew linkapps
brew cleanup
brew prune
brew cask cleanup

# TODO: Back-up and update script to run at log-in.
