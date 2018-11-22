#!/usr/bin/env bash

set -eu

sudo apt autoremove
sudo apt clean

sudo snap list --all | awk '/disabled/{print $1, $3}' |
    while read snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done
