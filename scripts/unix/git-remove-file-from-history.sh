#!/usr/bin/env bash

set -eu

git filter-branch --tag-name-filter cat --index-filter "git rm -r --cached --ignore-unmatch $1" --prune-empty -f -- --all
