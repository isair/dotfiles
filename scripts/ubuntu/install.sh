#!/usr/bin/env bash

set -ux

DEFAULT_PROFILE="personal"
PROFILE="${1:-$DEFAULT_PROFILE}"
PROFILE_PATH="../../profiles/${PROFILE}"

# Set working directory to the root of this script.
cd "$(dirname "$0")" || exit 1

# Make sure everthing is up-to-date
sudo apt-get update
sudo apt-get upgrade

# Install zsh
if ! hash zsh 2>/dev/null; then
  sudo apt-get install zsh
fi

# Install Oh My Zsh
if [ ! -d "${HOME}"/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) --unattended --skip-chsh"
  ZSH_PLUGINS_PATH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"/plugins
  mkdir -p "${ZSH_PLUGINS_PATH}"
  git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_PLUGINS_PATH}"/zsh-autosuggestions
  sudo chown -R "$(whoami)" /usr/local/share/zsh
  chmod -R g-w,o-w /usr/local/share/zsh /usr/local/share/zsh/site-functions
fi

# Install some essential cli stuff, TODO: Make them optional
if [ "$(command -v starship)" = "" ]; then
  curl -fsSL https://starship.rs/install.sh | bash
fi

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
if hash apt-get 2>/dev/null; then
  sudo apt-get install build-essential
elif hash yum 2>/dev/null; then
  sudo yum groupinstall 'Development Tools'
fi

# Install nvm and node, TODO: Fix detection
if [ "$(command -v nvm)" = "" ]; then
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.35.2/install.sh | bash
  export NVM_DIR="${HOME}"/.nvm
  source "${NVM_DIR}"/nvm.sh --install node
  nvm alias default node
fi

# Install chruby
if [ "$(command -v chruby)" = "" ]; then
  wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
  tar -xzvf chruby-0.3.9.tar.gz
  cd chruby-0.3.9
  sudo make install
  cd ..
  rm -rf chruby-0.3.9 chruby-0.3.9.tar.gz
fi

# Install ruby-install
if [ "$(command -v ruby-install)" = "" ]; then
  wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
  tar -xzvf ruby-install-0.7.0.tar.gz
  cd ruby-install-0.7.0
  sudo make install
  cd ..
  rm -rf ruby-install-0.7.0 ruby-install-0.7.0.tar.gz
fi

# Install yarn, TODO: Optional
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install --no-install-recommends yarn

# Install backed up packages.
if hash apt-get 2>/dev/null; then
  xargs sudo apt-get --yes --force-yes install < "${PROFILE_PATH}"/packages/apt.txt
fi
if hash snap 2>/dev/null; then
  xargs sudo snap install < "${PROFILE_PATH}"/packages/snap.txt
fi
xargs npm install --global < "${PROFILE_PATH}"/packages/npm.txt
sudo pip install -r "${PROFILE_PATH}"/packages/python.txt

# TODO: Symlink scripts to /usr/local/bin and add cron jobs for them.

# Configure git
if hash git 2>/dev/null; then
  git config --global core.autocrlf input
fi

# Clean things up
"${PWD}"/cleanup.sh

# Symlink dotfiles
"${PWD}"/../unix/symlink-dotfiles.sh "${PROFILE}"

# Ensure we can switch shell, TODO: Regex for empty space
sudo sed -i 's/required   pam_shells.so/sufficient   pam_shells.so/g' /etc/pam.d/chsh

# Create secrets file if it doesn't exist
touch "${HOME}"/.secrets

# Switch shell
chsh -s "$(/usr/bin/env zsh)"
