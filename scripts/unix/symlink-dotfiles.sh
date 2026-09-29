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

source ./utils/helpers.sh

abortIfSudo

setProfileEnv "$1"

abortIfProfileNotFound
resolveProfileChain

set -u

profilesRoot="$(cd "${PROFILES_PATH}" && pwd)"

rm -rf ~/.dotfiles-shared
ln -s "${profilesRoot}"/shared ~/.dotfiles-shared

for profileName in "${PROFILE_CHAIN[@]}"; do
  configs="${profilesRoot}/${profileName}/configurations"
  [ -d "${configs}" ] || continue
  for configName in profile bashrc zshenv zshrc vimrc hyper.js ssh_config; do
    [ -f "${configs}/${configName}" ] || continue
    if [ "${configName}" = ssh_config ]; then
      mkdir -p ~/.ssh
      destination=~/.ssh/config
    else
      destination=~/."${configName}"
    fi
    rm -f "${destination}"
    ln -s "${configs}/${configName}" "${destination}"
  done
  if [ -d "${configs}/config" ]; then
    mkdir -p ~/.config
    for configDir in "${configs}"/config/*/; do
      [ -d "${configDir}" ] || continue
      configName="$(basename "${configDir}")"
      rm -rf ~/.config/"${configName}"
      ln -s "${configDir%/}" ~/.config/"${configName}"
    done
  fi
done
