#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")" || exit 1

DEFAULT_PROFILE="personal"
BACKUP_PATH=../../profiles/"${1:-$DEFAULT_PROFILE}"/packages

mkdir -p "${BACKUP_PATH}"

/usr/local/bin/brew leaves > "${BACKUP_PATH}"/brew.txt
/usr/local/bin/brew cask list > "${BACKUP_PATH}"/brew-cask.txt

npm list --global --parseable --depth=0 | sed '1d' | awk '{gsub(/\/.*\//,"",$1); print}' > "${BACKUP_PATH}"/npm.txt

pip freeze > "${BACKUP_PATH}"/python.txt