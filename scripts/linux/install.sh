#!/usr/bin/env bash

# set -e

cd "$(dirname "$0")" || exit 1

source ../unix/utils/helpers.sh

abortIfSudo

setProfileEnv "$1"

abortIfProfileNotFound
resolveProfileChain

set -ux

# Make sure everthing is up-to-date
"${PWD}"/../unix/update.sh

# Install homebrew
if hasPackages brew && ! hasBinary brew; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  if hasBinary apt-get; then
    sudo apt-get install build-essential
  elif hasBinary pacman; then
    sudo pacman -S --noconfirm base-devel
  elif hasBinary yay; then
    yay -S --noconfirm base-devel
  elif hasBinary yum; then
    sudo yum groupinstall 'Development Tools'
  fi
fi

# Install backed up packages

if hasPackages apt-get; then
  if ! hasBinary apt-get; then
    echoError 'This profile has apt packages but apt could not be found in path'
  fi
  # TODO: Better way to install locales
  sudo apt-get --yes --force-yes install locales && sudo localedef -i en_US -f UTF-8 en_US.UTF-8
  for packageFile in "${PACKAGE_FILES[@]}"; do
    readPackageNames "${packageFile}"
    if [ -n "${PACKAGES[*]-}" ]; then sudo apt-get --yes --force-yes install "${PACKAGES[@]}"; fi
  done
fi

if hasPackages snap; then
  if ! hasBinary snap; then
    echoError 'This profile has snap packages but snap could not be found in path'
  fi
  for packageFile in "${PACKAGE_FILES[@]}"; do
    readPackageNames "${packageFile}"
    if [ -n "${PACKAGES[*]-}" ]; then sudo snap install "${PACKAGES[@]}"; fi
  done
fi

# ArchLinux support

if hasPackages pacman; then
  if ! hasBinary pacman; then
    echoError 'This profile has pacman packages but pacman could not be found in path'
  fi
  # The system was already refreshed and upgraded by update.sh above, so install
  # with -S (not -Sy) to avoid a partial upgrade.
  sudo pacman --noconfirm -S glibc
  sudo localedef -i en_US -f UTF-8 en_US.UTF-8
  for packageFile in "${PACKAGE_FILES[@]}"; do
    readPackageNames "${packageFile}"
    if [ -n "${PACKAGES[*]-}" ]; then sudo pacman --noconfirm -S "${PACKAGES[@]}"; fi
  done
fi

if hasPackages yay; then
  if ! hasBinary yay; then
    echoError 'This profile has yay packages but yay could not be found in path'
  fi
  # yay refuses to run as root and calls sudo itself, so it must NOT be prefixed
  # with sudo. yay.txt holds AUR packages only; the base system and locale are
  # handled by the pacman section above (yay requires pacman).
  for packageFile in "${PACKAGE_FILES[@]}"; do
    readPackageNames "${packageFile}"
    if [ -n "${PACKAGES[*]-}" ]; then yay --noconfirm -S "${PACKAGES[@]}"; fi
  done
fi

# RedHat based support

if hasPackages yum; then
  if ! hasBinary yum; then
    echoError 'This profile has yum packages but yum could not be found in path'
  fi
  sudo yum install -y glibc-common
  sudo localedef -i en_US -f UTF-8 en_US.UTF-8
  for packageFile in "${PACKAGE_FILES[@]}"; do
    readPackageNames "${packageFile}"
    if [ -n "${PACKAGES[*]-}" ]; then sudo yum install -y "${PACKAGES[@]}"; fi
  done
fi

if hasPackages brew; then
  if ! hasBinary brew; then
    echoError 'This profile has homebrew packages but brew could not be found in path'
  fi
  for packageFile in "${PACKAGE_FILES[@]}"; do
    readPackageNames "${packageFile}"
    if [ -n "${PACKAGES[*]-}" ]; then brew install "${PACKAGES[@]}"; fi
  done
fi

if hasPackages npm; then
  ## TODO: If nvm is installed, make sure a node version is installed
  if hasBinary npm; then
    for packageFile in "${PACKAGE_FILES[@]}"; do
      readPackageNames "${packageFile}"
      if [ -n "${PACKAGES[*]-}" ]; then npm install --global "${PACKAGES[@]}"; fi
    done
  fi
fi

if hasPackages python; then
  if ! hasBinary pip; then
    echoError 'This profile has python packages but does not install pip'
  fi
  for packageFile in "${PACKAGE_FILES[@]}"; do
    sudo pip install -r "${packageFile}"
  done
fi

# Configure zsh
if hasConfig zshrc; then
  if ! hasBinary zsh; then
    echoError 'This profile has a zsh configuration file but does not install zsh itself'
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
fi

# Fix Android SDK
if [ -d /usr/lib/android-sdk ]; then
  wget https://dl.google.com/android/repository/commandlinetools-linux-6514223_latest.zip
  unzip commandlinetools-linux-6514223_latest.zip
  sudo cp -r tools/* /usr/lib/android-sdk/tools/
  rm -rf tools commandlinetools-linux-6514223_latest.zip
fi

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
if hasConfig zshrc; then
  sudo sed -i 's/required   pam_shells.so/sufficient   pam_shells.so/g' /etc/pam.d/chsh # Ensure we can switch shell, TODO: Regex for empty space
  chsh -s "$(command -v zsh)"
fi
