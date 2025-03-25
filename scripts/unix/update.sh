#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")" || exit 1

source ./utils/helpers.sh

cd ../.. || exit 1

USER="$(getInstallationUser)"
PROJECT_DIR="$(universalRealPath "$(dirname "$0")")"/../..

# Keep profiles up to date

if [ -d .git ]; then
  if [ -z "$(git status --porcelain)" ]; then
    su - "${USER}" -c "cd ${PROJECT_DIR} && git pull --rebase"
  else
    su - "${USER}" -c "cd ${PROJECT_DIR} && git add . && git stash && git pull --rebase && git stash pop"
  fi
fi

# Keep system and installed packages up to date

if hasBinary softwareupdate; then
  sudo softwareupdate -i -a
fi

if hasBinary apt-get; then
  sudo apt-get update
  sudo apt-get upgrade
fi

if hasBinary pacman; then
  sudo pacman -Sy
  sudo pacman -Su
fi

if hasBinary yum; then
  sudo yum makecache
  sudo yum upgrade -y
fi

if hasBinary brew; then
  su - "${USER}" -c 'brew update && brew upgrade'
fi