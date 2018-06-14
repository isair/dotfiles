#!/usr/bin/env bash

rm -rf "$HOME/Library/Application Support/MobileSync/Backup"

brew cleanup
brew prune
brew cask cleanup

xcrun simctl delete unavailable
sudo rm -rf ~/Library/Developer/Xcode/DerivedData
