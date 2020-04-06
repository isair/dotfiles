#!/usr/bin/env bash

set -u

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

if hash snap 2>/dev/null; then
  sudo snap list --all | awk '/disabled/{print $1, $3}' |
      while read snapname revision; do
          sudo snap remove "$snapname" --revision="$revision"
      done
fi

find "${HOME}"/{projects,workspace} -maxdepth 4 -type d -regex ".*/build" -exec rm -rf {} + 2>/dev/null

if [ "${CLEAN_DEEP}" = 1 ]; then
  if hash yarn 2>/dev/null; then
    yarn cache clean
  fi
  find "${HOME}"/{projects,workspace} -maxdepth 4 -type d -regex ".*/(node_modules|ruby_gems|vendor|\.venv)" -exec rm -rf {} + 2>/dev/null
fi
