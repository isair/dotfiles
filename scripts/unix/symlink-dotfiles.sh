#!/usr/bin/env bash

DEFAULT_PROFILE="personal"

cd $(dirname "$0")/../../profiles/"${1:-$DEFAULT_PROFILE}"/configurations

rm ~/.bashrc
ln -s "$PWD/bashrc" ~/.bashrc

rm ~/.zshrc
ln -s "$PWD/zshrc" ~/.zshrc

rm ~/.vimrc
ln -s "$PWD/vimrc" ~/.vimrc
