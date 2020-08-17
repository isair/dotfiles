#!/usr/bin/env bash

cd "$(dirname "$0")" || exit 1

ln -s "${PWD}"/install.sh /usr/local/bin/ 
ln -s "${PWD}"/backup.sh /usr/local/bin/
ln -s "${PWD}"/cleanup.sh /usr/local/bin/
ln -s "${PWD}"/update.sh /usr/local/bin/
ln -s "${PWD}"/symlink-dotfiles.sh /usr/local/bin/
ln -s "${PWD}"/symlink-scripts.sh /usr/local/bin/