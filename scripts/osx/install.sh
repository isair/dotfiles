#!/usr/bin/env bash

DEFAULT_PROFILE="personal"
PROFILE="${1:-$DEFAULT_PROFILE}"
PROFILE_PATH="../../profiles/${PROFILE}"

# Set working directory to the root of this script.
cd "$(dirname "$0")" || exit 1

# Check for Xcode installation
if ! hash xcode-select 2>/dev/null; then
  echo Xcode needs to be installed
  exit
fi

# Install command line tools
if [ ! "$(xcode-select -p)" = "" ]; then
  xcode-select --install
fi

# Make sure everthing is up-to-date
sudo softwareupdate -i -a

# Install Oh My Zsh
if [ ! -d "${HOME}"/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed 's:env zsh -l::g' | sed 's:chsh -s .*$::g')"
  ZSH_PLUGINS_PATH="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins
  mkdir -p "${ZSH_PLUGINS_PATH}"
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_PLUGINS_PATH}"/zsh-autosuggestions
fi

# Install Homebrew
if ! hash brew 2>/dev/null; then
  rm -rf "/usr/local/Cellar" "/usr/local/.git"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Make sure brew cask has access to older versions of packages.
brew tap caskroom/versions

# Make sure packages and their definitions are up-to-date
brew update
brew upgrade

# Install git
brew install git
brew install git-credential-osxkeychain helper
brew install git-lfs && git lfs install

# Configure git
git config --global core.autocrlf input

# Install nvm and node
if ! hash nvm 2>/dev/null; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.26.1/install.sh | bash
  source "${HOME}"/.nvm/nvm.sh
  nvm install node
  nvm alias default node
fi

# Install chruby, ruby-install, and latest ruby
# TODO: Switch to latest ruby, install latest bundler, shell should use latest ruby as well
if [ "$(command -v chruby)" = "" ]; then
  brew install chruby ruby-install
  ruby-install --latest ruby
fi

# Install Brew packages in the profile.
while read -r PACKAGE ; do brew install "${PACKAGE}" ; done < "${PROFILE_PATH}"/packages/brew.txt
while read -r CASK ; do brew cask install "${CASK}" ; done < "${PROFILE_PATH}"/packages/brew-cask.txt

# Reload QuickLook plugins
qlmanage -r

# Python, TODO: python global packages backup and install
brew install python

# Install essential node packages, TODO: node global packages backup and sync
npm i -g yarn
# npm i -g npm-which
# npm i -g devtool
# npm i -g http-server
# npm i -g react-native-cli

# TODO: Add scripts to cron and symlink to /usr/local/bin

# Clean things up
"$PWD/cleanup.sh"

# Symlink dotfiles
"$PWD/../unix/symlink-dotfiles.sh" "${PROFILE}"

# Switch shell
chsh -s "$(grep /zsh$ /etc/shells | tail -1)"
