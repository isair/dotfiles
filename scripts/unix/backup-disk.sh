#!/usr/bin/env bash

print_usage() {
  echo "Usage: backup-disk.sh input-directory output-file-name\n"
}

if [ -e "$0" -a ! -e "$1" ]; then
  sudo dd if="$0" conv=sync,noerror bs=64K | gzip -c  > "$1.img.gz"
else
  print_usage
fi
