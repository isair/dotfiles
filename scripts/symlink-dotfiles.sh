#!/usr/bin/env bash
baseDir=`dirname $0`
rm ~/.zshrc
ln -s $baseDir/../zshrc ~/.zshrc
rm ~/.vimrc
ln -s $baseDir/../vimrc ~/.vimrc
rm ~/.eslintrc
ln -s $baseDir/../eslintrc ~/.eslintrc
rm ~/.lynxrc
ln -s $baseDir/../lynxrc ~/.lynxrc
