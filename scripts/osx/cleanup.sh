#!/usr/bin/env bash

set -eu

CLEAN_DEEP=0

while test $# -gt 0
do
  case "$1" in
    --deep) CLEAN_DEEP=1
      ;;
    -d) CLEAN_DEEP=1
      ;;
    *) echo "bad option $1"
      ;;
  esac
  shift
done

if [ "${CLEAN_DEEP}" = 1 ]; then
  echo "Doing deep clean..."
else
  echo "Doing shallow clean..."
fi

rm -rf "${HOME}/Library/Developer/Xcode/Archives"
rm -rf "${HOME}/Library/Developer/Xcode/Products"
rm -rf "${HOME}/Library/Developer/Xcode/DerivedData"
find -E "${HOME}"/{projects,.jenkins} -maxdepth 6 -type d -regex ".*/(DerivedData|build)" -exec rm -rf {} +

brew cleanup --prune-prefix
sudo xcrun simctl delete unavailable

if [ "${CLEAN_DEEP}" = 1 ]; then
  rm -rf "${HOME}/.jenkins/workspace"
  find -E "${HOME}/projects" -maxdepth 6 -type d -regex ".*/(node_modules|ruby_gems|vendor|\.venv)" -exec rm -rf {} +
  sudo rm -rf "${HOME}/Library/Application Support/MobileSync/Backup"
fi
