#!/usr/bin/env bash
baseDir=`dirname $0`
rm ~/.zshrc
ln -s $baseDir/../zshrc ~/.zshrc
rm ~/.vimrc
ln -s $baseDir/../vimrc ~/.vimrc
rm ~/.emacs
ln -s $baseDir/../emacs ~/.emacs
rm ~/.eslintrc
ln -s $baseDir/../eslintrc ~/.eslintrc
