#!/usr/bin/env bash

set -e

cd "$(dirname "$0")" || exit 1

source ./utils/helpers.sh

abortIfSudo

setProfileEnv "$1"

set -u

printf "Backing up... "

# Ensure backup path exists.
mkdir -p "${PACKAGES_PATH}"

# Since this script will be run via cron as well, ensure PATH is correct.
PATH=/usr/local/bin:"${PATH}"

# Back-up packages.

if hasBinary apt-get; then
  apt-mark showmanual | sort | grep -v -F -f <(apt show "$(apt-mark showmanual)" 2> /dev/null | grep -e ^Depends -e ^Pre-Depends | sed 's/^Depends: //; s/^Pre-Depends: //; s/(.*)//g; s/:any//g' | tr -d ',|' | tr ' ' '\n' | grep -v ^$ | sort -u) > "${PACKAGES_PATH}"/apt.txt
fi

if hasBinary snap; then
  snap list | awk '{if (NR > 1) print $1}' > "${PACKAGES_PATH}"/snap.txt
fi

if hasBinary brew; then
  brew leaves > "${PACKAGES_PATH}"/brew.txt
  if isMac; then
    brew list --cask > "${PACKAGES_PATH}"/brew-cask.txt
  fi
fi

# if hasBinary nix-env; then
#   nix-env -q > "${PACKAGES_PATH}"/nix.txt
# fi

if hasBinary npm; then
  npm list --global --parseable --depth=0 | sed '1d' | awk '{gsub(/\/.*\//,"",$1); print}' > "${PACKAGES_PATH}"/npm.txt
fi

if hasBinary pip; then
  pip freeze > "${PACKAGES_PATH}"/python.txt
fi

# Back-up configurations.

mkdir -p "${CONFIGS_PATH}"

if [ -f ~/.profile ]; then
  cp -L ~/.profile "${CONFIGS_PATH}"/profile | true
fi

if [ -f ~/.bashrc ]; then
  cp -L ~/.bashrc "${CONFIGS_PATH}"/bashrc | true
fi

if [ -f ~/.zshrc ]; then
  cp -L ~/.zshrc "${CONFIGS_PATH}"/zshrc | true
fi

if [ -f ~/.vimrc ]; then
  cp -L ~/.vimrc "${CONFIGS_PATH}"/vimrc | true
fi

if [ -f ~/.hyper.js ]; then
  cp -L ~/.hyper.js "${CONFIGS_PATH}"/hyper.js | true
fi

if [ -f ~/.ssh/config ]; then
  cp -L ~/.ssh/config "${CONFIGS_PATH}"/ssh_config | true
fi

./symlink-dotfiles.sh "${PROFILE}"

# Notify of success
echo "done!"
