#!/usr/bin/env bash

rm -rf "~/Library/Application Support/MobileSync/Backup"

brew linkapps
brew cleanup
brew prune
brew cask cleanup

xcrun simctl delete unavailable
