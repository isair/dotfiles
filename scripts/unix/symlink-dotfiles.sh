#!/usr/bin/env bash

cd $(dirname "$0")/../..

rm ~/.bashrc
ln -s "$PWD/bashrc" ~/.bashrc

rm ~/.zshrc
ln -s "$PWD/zshrc" ~/.zshrc

rm ~/.vimrc
ln -s "$PWD/vimrc" ~/.vimrc
