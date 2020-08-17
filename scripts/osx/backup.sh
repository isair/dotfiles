#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")" || exit 1

DEFAULT_PROFILE="personal"
BACKUP_PATH=../../profiles/"${1:-$DEFAULT_PROFILE}"/packages

# Ensure backup path exists.
mkdir -p "${BACKUP_PATH}"

# Since this script will be run via cron as well, ensure PATH is correct.
PATH=/usr/local/bin:"${PATH}"

brew leaves > "${BACKUP_PATH}"/brew.txt
brew cask list > "${BACKUP_PATH}"/brew-cask.txt

if hash npm 2>/dev/null; then
  npm list --global --parseable --depth=0 | sed '1d' | awk '{gsub(/\/.*\//,"",$1); print}' > "${BACKUP_PATH}"/npm.txt
fi

if hash pip 2>/dev/null; then
  pip freeze > "${BACKUP_PATH}"/python.txt
fi