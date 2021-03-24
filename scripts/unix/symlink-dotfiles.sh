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
  rm ~/.profile 2>/dev/null
  ln -s "${PWD}"/profile ~/.profile
fi

if [ -f bashrc ]; then
  rm ~/.bashrc 2>/dev/null
  ln -s "${PWD}"/bashrc ~/.bashrc
fi

if [ -f zshrc ]; then
  rm ~/.zshrc 2>/dev/null
  ln -s "${PWD}"/zshrc ~/.zshrc
fi

if [ -f vimrc ]; then
  rm ~/.vimrc 2>/dev/null
  ln -s "${PWD}"/vimrc ~/.vimrc
fi

if [ -f hyper.js ]; then
  rm ~/.hyper.js 2>/dev/null
  ln -s "${PWD}"/hyper.js ~/.hyper.js
fi
