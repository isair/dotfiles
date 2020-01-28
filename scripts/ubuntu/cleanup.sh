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

sudo apt autoremove
sudo apt clean

sudo snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done

find -E "${HOME}"/projects -maxdepth 4 -type d -regex ".*/build" -exec rm -rf {} +

if [ "${CLEAN_DEEP}" = 1 ]; then
  if hash yarn 2>/dev/null; then
    yarn cache clean
  fi
  find -E "${HOME}"/projects -maxdepth 4 -type d -regex ".*/(node_modules|ruby_gems|vendor|\.venv)" -exec rm -rf {} +
fi
