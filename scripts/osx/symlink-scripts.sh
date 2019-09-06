#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")"/.. || exit 1

ln -s "${PWD}"/osx/install.sh /usr/local/bin/ 
ln -s "${PWD}"/osx/backup.sh /usr/local/bin/
ln -s "${PWD}"/osx/cleanup.sh /usr/local/bin/
ln -s "${PWD}"/unix/symlink-dotfiles.sh /usr/local/bin/
