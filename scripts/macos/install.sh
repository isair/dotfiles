#!/usr/bin/env bash

set -e

cd "$(dirname "$0")" || exit 1

source ../unix/utils/helpers.sh

abortIfSudo

setProfileEnv "$1"

abortIfProfileNotFound

set -u

# Check for Xcode installation
if ! hasBinary xcode-select; then
  echoError 'Xcode needs to be installed'
fi

# Install command line tools
if [ ! "$(xcode-select -p)" = "" ]; then
  # TODO: This will fail if already installed, so we do `|| true`, but we should do some actual verification instead.
  xcode-select --install || true
fi

# Make sure everthing is up-to-date
"${PWD}"/../unix/update.sh

# Install Oh My Zsh
if hasConfig zsh; then
  if [ ! -d "${HOME}"/.oh-my-zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended --skip-chsh"
    ZSH_PLUGINS_PATH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins
    mkdir -p "${ZSH_PLUGINS_PATH}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_PLUGINS_PATH}"/zsh-autosuggestions
    sudo chown -R "$(whoami)" /usr/local/share/zsh
    chmod -R g-w,o-w /usr/local/share/zsh /usr/local/share/zsh/site-functions
  fi
fi

# Install Homebrew
if hasPackages brew; then
  if ! hasBinary brew; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  # Make sure brew cask has access to older versions of packages.
  brew tap homebrew/cask-versions

  # Make sure packages and their definitions are up-to-date
  brew update
  brew upgrade
fi

# Install nvm and node TODO: Make this play better with nvm and node coming from profile
if hasPackages npm && [ "$(command -v nvm)" = "" ]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.2/install.sh | bash
  export NVM_DIR="${HOME}"/.nvm
  source "${NVM_DIR}"/nvm.sh --install node
  nvm alias default node
fi

# Install backed up packages.

if hasPackages brew; then
  if ! hasBinary brew; then
    echoError 'This profile has homebrew packages but brew could not be found in path'
  fi
  brew install `cat "${PACKAGES_PATH}"/brew.txt | tr '\n' ' '`
fi

if hasPackages brew-cask; then
  if ! hasBinary brew; then
    echoError 'This profile has homebrew casks but brew could not be found in path'
  fi
  brew cask install `cat "${PACKAGES_PATH}"/brew-cask.txt | tr '\n' ' '`
fi

## TODO: If nvm is installed, make sure a node version is installed

if hasPackages npm; then
  if ! hasBinary npm; then
    echoError 'This profile has npm packages but npm could not be found in path'
  fi
  npm install --global `cat "${PACKAGES_PATH}"/npm.txt | tr '\n' ' '`
fi

if hasPackages python; then
  if ! hasBrewBinary pip; then # Enforce brew as default macOS python requires sudo
    echoError 'This profile has python packages but does not install pip via homebrew'
  fi
  pip install -r "${PACKAGES_PATH}"/python.txt
fi

# Reload QuickLook plugins
qlmanage -r

# Configure git
if hasBinary git; then
  git config --global core.autocrlf input
fi

# Clean things up
"${PWD}"/../unix/cleanup.sh

# Symlink dotfiles
"${PWD}"/../unix/symlink-dotfiles.sh "${PROFILE}"

# Create secrets file if it doesn't exist
touch "${HOME}"/.secrets

# Switch shell
if hasConfig zsh; then
  chsh -s "$(grep /zsh$ /etc/shells | tail -1)"
fi
