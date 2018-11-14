#!/usr/bin/env bash

set -eu

cd "$(dirname "$0")" || exit 1

DEFAULT_BACKUP_PATH="../../data/backup"

BACKUP_PATH="${1:-$DEFAULT_BACKUP_PATH}"

apt list | grep \\[installed\\] | awk -F/ '{print $1}' > "${BACKUP_PATH}"/apt-packages.txt
