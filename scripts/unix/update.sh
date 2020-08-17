#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")"/../.. || exit 1

# Keep profiles up to date

if [ -d .git ]; then
  if [ -z "$(git status --porcelain)" ]; then
    git pull
  else
    git add .
    git stash
    git pull
    git stash pop
  fi
fi

# Keep system and installed packages up to date

if hash brew 2>/dev/null; then
  brew update && brew upgrade
fi

if hash softwareupdate 2>/dev/null; then
  sudo softwareupdate -i -a
fi