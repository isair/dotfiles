#!/usr/bin/env bash

rm -rf "${HOME}/Library/Application Support/MobileSync/Backup"

rm -rf "${HOME}/Library/Developer/Xcode/Archives"
rm -rf "${HOME}/Library/Developer/Xcode/Products"
rm -rf "${HOME}/Library/Developer/Xcode/DerivedData"

brew cleanup --prune-prefix

sudo xcrun simctl delete unavailable
