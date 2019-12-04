#!/usr/bin/env bash

set -eu

brew update && brew upgrade

sudo softwareupdate -i -a
