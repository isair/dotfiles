#!/usr/bin/env bash

print_usage() {
  printf "Usage: backup-disk.sh input-device output-file-name\n"
}

if [ -e "$1" ] && [ -n "$2" ]; then
  sudo dd if="$1" conv=sync,noerror bs=64K | gzip -c > "$2.img.gz"
else
  print_usage
fi
