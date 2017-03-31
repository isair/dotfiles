#!/usr/bin/env bash

cd $(dirname "$0")/../..

rm ~/.zshrc
ln -s "$PWD/zshrc" ~/.zshrc

rm ~/.vimrc
ln -s "$PWD/vimrc" ~/.vimrc

rm ~/.eslintrc
ln -s "$PWD/eslintrc" ~/.eslintrc

rm ~/.lynxrc
ln -s "$PWD/lynxrc" ~/.lynxrc
