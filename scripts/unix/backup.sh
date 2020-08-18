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
    brew cask list > "${PACKAGES_PATH}"/brew-cask.txt
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

# Notify of success
echo "done!"