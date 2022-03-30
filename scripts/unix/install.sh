#!/usr/bin/env bash

# IMPORTANT: THIS IS AN EXPERIMENTAL INSTALL SCRIPT THAT AIMS TO
# UNIFY LINUX AND MACOS INSTALLATION SCRIPTS. DO NOT USE THIS
# AT THE MOMENT.

set -e

cd "$(dirname "$0")" || exit 1

source ./utils/helpers.sh

abortIfSudo

setProfileEnv "$1"

set -ux

# Make sure everthing is up-to-date

"${PWD}"/../unix/update.sh

if isMac; then
  # Check for Xcode installation
  if ! hasBinary xcode-select; then
    echoError 'Xcode needs to be installed'
  fi
  # Install command line tools
  if [ ! "$(xcode-select -p)" = "" ]; then
    xcode-select --install || true
  fi
fi

# Install nix
sudo umount /proc/{cpuinfo,diskstats,meminfo,stat,uptime}
curl -L https://nixos.org/nix/install | sh

# Install backed up nix packages.
nix-env -i `cat "${PACKAGES_PATH}"/nix.txt | tr '\n' ' '`

# Install backed up packages of tools installed via nix.

if hasBinary npm; then
  npm install --global `cat "${PACKAGES_PATH}"/npm.txt | tr '\n' ' '`
fi

if hasBinary pip; then
  sudo pip install -r "${PACKAGES_PATH}"/python.txt
fi

# Configure git TODO: Do this via nix home-manager
if hasBinary git; then
  git config --global core.autocrlf input
fi

# Configure starship TODO: Do this via nix home-manager
if hasBinary starship; then
  echo "eval \"$(starship init bash)\"\n" >> "${HOME}"/.profile
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
