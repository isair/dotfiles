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
if [[ $(xcode-select -p) -ne 0 ]]; then
  xcode-select --install
fi

# Make sure everthing is up-to-date
sudo softwareupdate -i -a

# Install Oh My Zsh
if [ ! -d "${HOME}"/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sed 's:env zsh -l::g' | sed 's:chsh -s .*$::g')"
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

# Install rbenv, ruby-builder, ruby and bundler
if ! hash rbenv 2>/dev/null; then
  brew install rbenv
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  LATEST_STABLE_RUBY=$(rbenv install -l | grep -v - | tail -1)
  rbenv install "${LATEST_STABLE_RUBY}"
  rbenv global "${LATEST_STABLE_RUBY}"
fi

if ! hash bundler 2>/dev/null; then
  gem install bundler
  rbenv rehash
fi

# Install Brew packages in the profile.
while read -r PACKAGE ; do brew install "${PACKAGE}" ; done < "${PROFILE_PATH}"/packages/brew.txt
while read -r CASK ; do brew cask install "${CASK}" ; done < "${PROFILE_PATH}"/packages/brew-cask.txt

# Reload QuickLook plugins
qlmanage -r

# Python and Python packages
brew install python
if [ "$1" != "--server" ]; then
  pip install -U subliminal
  pip install -U vncdotool
fi

# Install essential node packages
npm i -g yarn
npm i -g npm-which
npm i -g devtool
npm i -g http-server
if [ "$1" != "--server" ]; then
  npm i -g react-native-cli
fi

# TODO: Add scripts to cron and symlink to /usr/local/bin

# Clean things up
"$PWD/cleanup.sh"

# Symlink dotfiles
"$PWD/../unix/symlink-dotfiles.sh" "${PROFILE}"

# Switch shell
chsh -s "$(grep /zsh$ /etc/shells | tail -1)"
