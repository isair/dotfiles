#!/usr/bin/env bash

set -eu

if hash brew 2>/dev/null; then
  brew update && brew upgrade
fi

if hash softwareupdate 2>/dev/null; then
  sudo softwareupdate -i -a
fi