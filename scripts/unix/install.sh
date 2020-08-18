#!/usr/bin/env bash

# IMPORTANT: THIS IS AN EXPERIMENTAL INSTALL SCRIPT THAT AIMS TO
# UNIFY LINUX AND MACOS INSTALLATION SCRIPTS. DO NOT USE THIS
# AT THE MOMENT.

set -e

cd "$(dirname "$0")" || exit 1

source ./utils/helpers.sh

abortIfSudo

setProfileEnv "$1"

set -u

# Make sure everthing is up-to-date TODO: Other system package managers
if hasBinary apt-get; then
  sudo apt-get update
  sudo apt-get upgrade
elif hasBinary softwareupdate; then
  sudo softwareupdate -i -a
  # Check for Xcode installation
  if ! hasBinary xcode-select; then
    echo Xcode needs to be installed
    exit 1
  fi
  # Install command line tools
  if [ ! "$(xcode-select -p)" = "" ]; then
    xcode-select --install || true
  fi
fi

# Install nix
sudo umount /proc/{cpuinfo,diskstats,meminfo,stat,uptime}
curl -L https://nixos.org/nix/install | sh

# Install and set up a modern shell TODO: Make this work for zsh system too.
nix-env -i starship
echo "eval \"$(starship init bash)\"\n" >> "${HOME}"/.profile

# Install backed up nix packages.
xargs nix-env -i < "${PROFILE_PATH}"/packages/nix.txt

# TODO: Configure nix packages.

# Install backed up packages of tools installed via nix.

if hasBinary npm; then
  xargs npm install --global < "${PROFILE_PATH}"/packages/npm.txt
fi

if hasBinary pip; then
  sudo pip install -r "${PROFILE_PATH}"/packages/python.txt
fi

# Configure git TODO: Do this via nix home-manager
if hasBinary git; then
  git config --global core.autocrlf input
fi

# Symlink scripts
"${PWD}"/symlink-scripts.sh

# Clean things up
cleanup.sh

# Symlink dotfiles
symlink-dotfiles.sh "${PROFILE}"

# Ensure we can switch shell, TODO: Regex for empty space
sudo sed -i 's/required   pam_shells.so/sufficient   pam_shells.so/g' /etc/pam.d/chsh

# Create secrets file if it doesn't exist
touch "${HOME}"/.secrets

# TODO: Schedule backup and cleaning
