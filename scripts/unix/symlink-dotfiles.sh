#!/usr/bin/env bash

DEFAULT_PROFILE="personal"
PROFILE="${1:-$DEFAULT_PROFILE}"

cd $(dirname "$0")/../../profiles/"${PROFILE}"/configurations

rm -rf ~/.dotfiles-shared
ln -s "${PWD}"/../../shared ~/.dotfiles-shared

if [ -f profile ]; then
  rm ~/.profile
  ln -s "${PWD}"/profile ~/.profile
fi

if [ -f bashrc ]; then
  rm ~/.bashrc
  ln -s "${PWD}"/bashrc ~/.bashrc
fi

if [ -f zshrc ]; then
  rm ~/.zshrc
  ln -s "${PWD}"/zshrc ~/.zshrc
fi

if [ -f vimrc ]; then
  rm ~/.vimrc
  ln -s "${PWD}"/vimrc ~/.vimrc
fi

if [ -f hyper.js ]; then
  rm ~/.hyper.js
  ln -s "${PWD}"/hyper.js ~/.hyper.js
fi
