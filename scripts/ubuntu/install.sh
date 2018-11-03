#!/usr/bin/env bash

## Make sure everthing is up-to-date
sudo apt-get update
sudo apt-get upgrade

# Install some initial essentials
sudo apt-get install curl

# Configure git
git config --global core.autocrlf input

## Install Oh My Zsh
if ! hash zsh 2>/dev/null; then
  sudo apt-get install zsh
  chsh -s $(which zsh)
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

## Install nvm and node
if ! hash nvm 2>/dev/null; then
  # TODO
  echo "TODO"
fi

## Install rbenv, ruby-builder, ruby and bundler
if ! hash rbenv 2>/dev/null; then
  git clone https://github.com/rbenv/rbenv.git ~/.rbenv
  git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
  latest_stable_ruby=$(rbenv install -l | grep -v - | tail -1)
  rbenv install $latest_stable_ruby
  rbenv global $latest_stable_ruby
fi

if ! hash bundler 2>/dev/null; then
  gem install bundler
  rbenv rehash
fi

## Install essential node packages
npm i -g yarn
yarn global add npm-which
yarn global add devtool
yarn global add http-server
if [ "$1" != "-server" ]; then
  yarn global add react-native-cli
  yarn global add eslint
  yarn global add eslint-plugin-react
  yarn global add eslint-config-airbnb
  yarn global add babel-eslint
  yarn global add flow-bin
fi

## Clean things up
# TODO

## Symlink dotfiles
"$PWD/symlink-dotfiles.sh"
