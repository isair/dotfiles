#!/usr/bin/env bash

set -e

cd "$(dirname "$0")" || exit 1

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
