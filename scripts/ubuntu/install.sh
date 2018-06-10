#!/usr/bin/env bash

## Make sure everthing is up-to-date
# TODO

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
npm i -g npm-which
npm i -g devtool
npm i -g http-server
if [ "$1" != "-server" ]; then
  npm i -g react-native-cli
  npm i -g code-push-cli
  npm i -g eslint
  npm i -g eslint-plugin-react
  npm i -g eslint-config-airbnb
  npm i -g babel-eslint
  npm i -g flow-bin
fi

## Clean things up
# TODO

## Symlink dotfiles
"$PWD/symlink-dotfiles.sh"
