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

# Install Charles (web debugging proxy)
wget -q -O - https://www.charlesproxy.com/packages/apt/PublicKey | sudo apt-key add -
sudo sh -c 'echo deb https://www.charlesproxy.com/packages/apt/ charles-proxy main > /etc/apt/sources.list.d/charles.list'
sudo apt-get install charles-proxy

## Install yarn
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update && sudo apt-get install --no-install-recommends yarn

## Install essential node packages
npm install --global npm-which
npm install --global devtool
npm install --global http-server
npm install --global rimraf

## Clean things up
"$PWD/cleanup.sh"

## Symlink dotfiles
"$PWD/symlink-dotfiles.sh"
