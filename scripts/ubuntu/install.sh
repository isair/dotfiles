#!/usr/bin/env bash

## Make sure everthing is up-to-date
sudo apt-get update
sudo apt-get upgrade

# Install some initial essentials
sudo apt-get install curl vim xsel

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
  sudo apt-get install -y libssl-dev libreadline-dev zlib1g-dev
  eval "$(rbenv init -)"
  latest_stable_ruby=$(rbenv install -l | grep -v - | tail -1)
  rbenv install $latest_stable_ruby
  rbenv global $latest_stable_ruby
fi

if ! hash bundler 2>/dev/null; then
  gem install bundler
  rbenv rehash
fi

## Install Java 8 and set it as default
sudo add-apt-repository ppa:webupd8team/java
sudo apt install oracle-java8-installer oracle-java8-set-default

## Install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install --no-install-recommends yarn

## Install essential node packages
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
