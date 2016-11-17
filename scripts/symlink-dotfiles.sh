#!/usr/bin/env bash

cd $(dirname "$0")/..

rm ~/.zshrc
ln -s zshrc ~/.zshrc

rm ~/.vimrc
ln -s vimrc ~/.vimrc

rm ~/.eslintrc
ln -s eslintrc ~/.eslintrc

rm ~/.lynxrc
ln -s lynxrc ~/.lynxrc
