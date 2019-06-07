#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")" || exit 1

DEFAULT_PROFILE="personal"
BACKUP_PATH=../../profiles/"${1:-$DEFAULT_PROFILE}"/packages

/usr/local/bin/brew leaves > "${BACKUP_PATH}"/brew.txt
/usr/local/bin/brew cask list > "${BACKUP_PATH}"/brew-cask.txt
