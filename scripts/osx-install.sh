#!/usr/bin/env bash

# Make sure Xcode is installed before running this script

# Install command line tools if not installed
xcode-select -p
if [[ $? -ne 0 ]]; then
    xcode-select --install
fi

# Update all OSX packages
sudo softwareupdate -i -a

# Link airport binary
sudo ln -s /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport /usr/local/bin/airport

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install Homebrew if not installed
brew --version
if [[ $? -ne 0 ]]; then
    # Clean-up failed Homebrew install
    rm -rf "/usr/local/Cellar" "/usr/local/.git"
    # Install Homebrew
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi
brew update
brew upgrade

# Install essential packages
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

# Install mobile development packages
brew install xctool
brew install android-sdk

# Install security packages
# brew install otx
brew install gdb
brew install reaver
brew install aircrack-ng
brew install nmap
brew install theharvester

# Install NVM and the latest version of Node.js
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.26.1/install.sh | bash
nvm install node
nvm alias default node

# Install essential node packages
npm i -g npm-which
npm i -g devtool
npm i -g http-server
npm i -g react-native-cli
npm i -g eslint
npm i -g eslint-plugin-react
npm i -g eslint-config-airbnb
npm i -g babel-eslint
npm i -g flow-bin

# Install essential gems
sudo gem install cocoapods
sudo gem install gym
sudo gem install git-up

# Install essential python packages
sudo pip install -U subliminal

# Install Cask
brew tap caskroom/cask
brew install brew-cask

# Install essential apps
# brew cask install desktime
brew cask install macvim
brew cask install atom
brew cask install bettertouchtool
brew cask install gitup
brew cask install slack
brew cask install lastpass
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
brew cask install openemu    # TODO: Script for backing up ROMs and save files.
brew cask install bit-slicer
brew cask install onyx
brew cask install macupdate-desktop

# Paid apps
# brew cask install atext
brew cask install cleanmymac
brew cask install dash
# brew cask install omnigraffle
brew cask install daisydisk
brew cask install boom
# brew cask install bartender2
# brew cask install hopper
# brew cask install photosweeper-X

# Install atom packages
apm install vim-mode
apm install merge-conflicts
apm install nuclide
apm install git-plus

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
