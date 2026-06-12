#!/usr/bin/env bash

set -e

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

# Re-runnable: -f replaces any existing links. /usr/local/bin must be writable
# by the current user (true on Homebrew setups); otherwise run with sudo.
for script in install.sh backup.sh cleanup.sh update.sh symlink-dotfiles.sh symlink-scripts.sh; do
  ln -sf "${PWD}/${script}" /usr/local/bin/"${script}"
done
