#!/usr/bin/env bash
setenv SCRIPTDIR `dirname $0`
rm ~/.profile
ln -s $SCRIPTDIR/../profile ~/.profile
rm ~/.bash_profile
ln -s $SCRIPTDIR/../bash_profile ~/.bash_profile
rm ~/.zshrc
ln -s $SCRIPTDIR/../zshrc ~/.zshrc
rm ~/.vimrc
ln -s $SCRIPTDIR/../vimrc ~/.vimrc
rm ~/.eslintrc
ln -s $SCRIPTDIR/../eslintrc ~/.eslintrc
