#!/usr/bin/env bash
setenv SCRIPTDIR `dirname $0`
rm ~/.zshrc
ln -s $SCRIPTDIR/../zshrc ~/.zshrc
rm ~/.vimrc
ln -s $SCRIPTDIR/../vimrc ~/.vimrc
rm ~/.emacs
ln -s $SCRIPTDIR/../emacs ~/.emacs
rm ~/.eslintrc
ln -s $SCRIPTDIR/../eslintrc ~/.eslintrc
