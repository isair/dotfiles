#!/usr/bin/env bash

# IMPORTANT: THIS IS AN EXPERIMENTAL INSTALL SCRIPT THAT AIMS TO
# UNIFY LINUX AND MACOS BACKUP SCRIPTS. DO NOT USE THIS AT THE MOMENT.

set -eu

cd "$(dirname "$0")" || exit 1

DEFAULT_PROFILE="personal"
BACKUP_PATH=../../profiles/"${1:-$DEFAULT_PROFILE}"/packages

# Ensure backup path exists.
mkdir -p "${BACKUP_PATH}"

# Since this script will be run via cron as well, ensure PATH is correct.
PATH=/usr/local/bin:"${PATH}"

if hash nix-env 2>/dev/null; then
  nix-env -q > "${BACKUP_PATH}"/nix.txt
fi

if hash npm 2>/dev/null; then
  npm list --global --parseable --depth=0 | sed '1d' | awk '{gsub(/\/.*\//,"",$1); print}' > "${BACKUP_PATH}"/npm.txt
fi

if hash pip 2>/dev/null; then
  pip freeze > "${BACKUP_PATH}"/python.txt
fi

# if hash brew 2>/dev/null; then
#   brew leaves > "${BACKUP_PATH}"/brew.txt
#   brew cask list > "${BACKUP_PATH}"/brew-cask.txt
# fi

# if hash apt-get 2>/dev/null; then
#   apt-mark showmanual | sort | grep -v -F -f <(apt show "$(apt-mark showmanual)" 2> /dev/null | grep -e ^Depends -e ^Pre-Depends | sed 's/^Depends: //; s/^Pre-Depends: //; s/(.*)//g; s/:any//g' | tr -d ',|' | tr ' ' '\n' | grep -v ^$ | sort -u) > "${BACKUP_PATH}"/apt.txt
# fi

# if hash snap 2>/dev/null; then
#   snap list | awk '{if (NR > 1) print $1}' > "${BACKUP_PATH}"/snap.txt
# fi