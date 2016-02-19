#!/usr/bin/env bash
relativeDir=`dirname $0`
baseDir=`greadlink -f $relativeDir`
rm ~/.zshrc
ln -s $baseDir/../zshrc ~/.zshrc
rm ~/.vimrc
ln -s $baseDir/../vimrc ~/.vimrc
rm ~/.eslintrc
ln -s $baseDir/../eslintrc ~/.eslintrc
rm ~/.lynxrc
ln -s $baseDir/../lynxrc ~/.lynxrc
