#!/usr/bin/env bash

set -u # TODO: set -eu after silencing find errors

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

if hasBinary pacman; then
  # --noconfirm: cleanup.sh is meant to run unattended via cron.
  sudo pacman -Sc --noconfirm
fi

if hasBinary yum; then
  sudo yum autoremove -y
  sudo yum clean all
fi

if hasBinary brew; then
  su - "${USER}" -c 'brew cleanup --prune-prefix'
fi

if hasBinary nix-env; then
  if [ "${CLEAN_DEEP}" = 1 ]; then
    su - "${USER}" -c 'nix-env --delete-generations +1'
  else
    su - "${USER}" -c 'nix-env --delete-generations 30d'
  fi
fi

if isMac; then
  # macOS shallow clean-up
  su - "${USER}" -c 'rm -rf ~/Library/Developer/Xcode/Archives'
  su - "${USER}" -c 'rm -rf ~/Library/Developer/Xcode/Products'
  su - "${USER}" -c 'rm -rf ~/Library/Developer/Xcode/DerivedData'
  su - "${USER}" -c 'find -E ~/{projects,workspace} -maxdepth 4 -type d -regex ".*/(DerivedData|build)" -exec rm -rf {} +'
  su - "${USER}" -c 'find -E ~/.jenkins/workspace -maxdepth 3 -type d -regex ".*/(ios|android)" -execdir git clean -xdf -- {} +'
  sudo xcrun simctl delete unavailable
else
  # Linux shallow clean-up of user owned programming projects
  su - "${USER}" -c 'find ~/{projects,workspace} -maxdepth 4 -type d -regex ".*/build" -exec rm -rf {} + 2>/dev/null'
fi

# Deep clean of caches and user owned programming projects

if [ "${CLEAN_DEEP}" = 1 ]; then
  if hasBinary yarn; then
    su - "${USER}" -c 'yarn cache clean'
  fi
  su - "${USER}" -c 'find ~/{projects,workspace} -maxdepth 4 -type d -regex ".*/(node_modules|ruby_gems|vendor|\.venv)" -exec rm -rf {} + 2>/dev/null'
  su - "${USER}" -c 'rm -rf ~/.jenkins/workspace'
  su - "${USER}" -c 'rm -rf ~/"Library/Application Support/MobileSync/Backup"'
fi

# Notify of success

echo "done!"