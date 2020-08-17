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

# Install homebrew
if ! hash brew 2>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  if hash apt-get 2>/dev/null; then
    sudo apt-get install build-essential
  elif hash yum 2>/dev/null; then
    sudo yum groupinstall 'Development Tools'
  fi
fi

# Install backed up packages

while read -r PACKAGE ; do brew install "${PACKAGE}" ; done < "${PROFILE_PATH}"/packages/brew.txt

if hash apt-get 2>/dev/null; then
  # TODO: Better way to install locales
  sudo apt-get --yes --force-yes install locales && sudo localedef -i en_US -f UTF-8 en_US.UTF-8
  xargs sudo apt-get --yes --force-yes install < "${PROFILE_PATH}"/packages/apt.txt
fi

if hash snap 2>/dev/null; then
  xargs sudo snap install < "${PROFILE_PATH}"/packages/snap.txt
fi

if hash npm 2>/dev/null; then
  xargs npm install --global < "${PROFILE_PATH}"/packages/npm.txt
fi

if hash pip 2>/dev/null; then
  sudo pip install -r "${PROFILE_PATH}"/packages/python.txt
fi

# Fix Android SDK
if [ -d /usr/lib/android-sdk ]; then
  wget https://dl.google.com/android/repository/commandlinetools-linux-6514223_latest.zip
  unzip commandlinetools-linux-6514223_latest.zip
  sudo cp -r tools/* /usr/lib/android-sdk/tools/
  rm -rf tools commandlinetools-linux-6514223_latest.zip
fi

# Configure git
if hash git 2>/dev/null; then
  git config --global core.autocrlf input
fi

# Clean things up
"${PWD}"/../unix/cleanup.sh

# Symlink dotfiles
"${PWD}"/../unix/symlink-dotfiles.sh "${PROFILE}"

# Ensure we can switch shell, TODO: Regex for empty space
sudo sed -i 's/required   pam_shells.so/sufficient   pam_shells.so/g' /etc/pam.d/chsh

# Create secrets file if it doesn't exist
touch "${HOME}"/.secrets

# Switch shell
chsh -s "$(/usr/bin/env zsh)"
