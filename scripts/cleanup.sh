#!/usr/bin/env bash

brew linkapps
brew cleanup
brew prune
brew cask cleanup
xcrun simctl delete unavailable
