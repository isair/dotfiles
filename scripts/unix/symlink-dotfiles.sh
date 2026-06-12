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

set -u

cd "${CONFIGS_PATH}"

rm -rf ~/.dotfiles-shared
ln -s "${PWD}"/../../shared ~/.dotfiles-shared

if [ -f profile ]; then
  rm -f ~/.profile
  ln -s "${PWD}"/profile ~/.profile
fi

if [ -f bashrc ]; then
  rm -f ~/.bashrc
  ln -s "${PWD}"/bashrc ~/.bashrc
fi

if [ -f zshenv ]; then
  rm -f ~/.zshenv
  ln -s "${PWD}"/zshenv ~/.zshenv
fi

if [ -f zshrc ]; then
  rm -f ~/.zshrc
  ln -s "${PWD}"/zshrc ~/.zshrc
fi

if [ -f vimrc ]; then
  rm -f ~/.vimrc
  ln -s "${PWD}"/vimrc ~/.vimrc
fi

if [ -f hyper.js ]; then
  rm -f ~/.hyper.js
  ln -s "${PWD}"/hyper.js ~/.hyper.js
fi

if [ -f ssh_config ]; then
  rm -f ~/.ssh/config
  ln -s "${PWD}"/ssh_config ~/.ssh/config
fi

if [ -d config ]; then
  mkdir -p ~/.config
  for configDir in config/*/; do
    [ -d "${configDir}" ] || continue
    configName="$(basename "${configDir}")"
    rm -rf ~/.config/"${configName}"
    ln -s "${PWD}"/config/"${configName}" ~/.config/"${configName}"
  done
fi
