#!/usr/bin/env bash

DEFAULT_PROFILE="personal"

cd $(dirname "$0")/../../profiles/"${1:-$DEFAULT_PROFILE}"/configurations

rm -rf ~/.dotfiles-shared
ln -s "${PWD}"/../../shared ~/.dotfiles-shared

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
