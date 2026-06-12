#!/usr/bin/env bash

set -eu

# Resolve this script's real directory, even when invoked through a symlink
# (e.g. from /usr/local/bin), so the relative paths below still resolve.
selfPath="${BASH_SOURCE[0]}"
while [ -L "${selfPath}" ]; do
  selfDir="$(cd -P "$(dirname "${selfPath}")" > /dev/null 2>&1 && pwd)"
  selfPath="$(readlink "${selfPath}")"
  case "${selfPath}" in
    /*) ;;
    *) selfPath="${selfDir}/${selfPath}" ;;
  esac
done
cd "$(cd -P "$(dirname "${selfPath}")" > /dev/null 2>&1 && pwd)" || exit 1

source ./utils/helpers.sh

cd ../.. || exit 1

USER="$(getInstallationUser)"
# We are now at the repository root (scripts/unix/../..).
PROJECT_DIR="$PWD"

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

# TODO: yum support

if hasBinary brew; then
  su - "${USER}" -c 'brew update && brew upgrade'
fi