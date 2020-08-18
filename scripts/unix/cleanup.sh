#!/usr/bin/env bash

set -u # TODO: set -eu after silencing find errors

cd "$(dirname "$0")" || exit 1

source ./utils/helpers.sh

# Parse arguments

CLEAN_DEEP=0

while test $# -gt 0
do
  case "$1" in
    --deep) CLEAN_DEEP=1
      ;;
    -d) CLEAN_DEEP=1
      ;;
    *) echo "bad option $1"
      ;;
  esac
  shift
done

if [ "${CLEAN_DEEP}" = 1 ]; then
  printf "Doing deep clean... "
else
  printf "Doing shallow clean... "
fi

# Package manager garbage collection

if hasBinary apt-get; then
  sudo apt autoremove
  sudo apt clean
fi

if hasBinary snap; then
  sudo snap list --all | awk '/disabled/{print $1, $3}' |
      while read snapname revision; do
          sudo snap remove "$snapname" --revision="$revision"
      done
fi

if hasBinary brew; then
  brew cleanup --prune-prefix
fi

if hasBinary nix-env; then
  if [ "${CLEAN_DEEP}" = 1 ]; then
    nix-env --delete-generations +1
  else
    nix-env --delete-generations 30d
  fi
fi

if isMac; then
  # macOS shallow clean-up
  rm -rf "${HOME}/Library/Developer/Xcode/Archives"
  rm -rf "${HOME}/Library/Developer/Xcode/Products"
  rm -rf "${HOME}/Library/Developer/Xcode/DerivedData"
  find -E "${HOME}"/{projects,workspace} -maxdepth 4 -type d -regex ".*/(DerivedData|build)" -exec rm -rf {} +
  find -E "${HOME}"/.jenkins/workspace -maxdepth 3 -type d -regex ".*/(ios|android)" -execdir git clean -xdf -- {} +
  sudo xcrun simctl delete unavailable
else
  # Linux shallow clean-up of user owned programming projects
  find "${HOME}"/{projects,workspace} -maxdepth 4 -type d -regex ".*/build" -exec rm -rf {} + 2>/dev/null
fi

# Deep clean of caches and user owned programming projects

if [ "${CLEAN_DEEP}" = 1 ]; then
  if hasBinary yarn; then
    yarn cache clean
  fi
  find "${HOME}"/{projects,workspace} -maxdepth 4 -type d -regex ".*/(node_modules|ruby_gems|vendor|\.venv)" -exec rm -rf {} + 2>/dev/null
  rm -rf "${HOME}/.jenkins/workspace"
  sudo rm -rf "${HOME}/Library/Application Support/MobileSync/Backup"
fi

# Notify of success

echo "done!"