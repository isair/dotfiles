#!/usr/bin/env bash

set -eu

# Check if we have the necessary permissions to perform the backup.
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run backup as root."
  exit 1
fi

# Check if we have space for a backup.
diskSize=$(df . | awk '{print $2}' | tail -n 1)
emptySpace=$(df . | awk '{print $4}' | tail -n 1)
spaceNeeded=$(($(du -s /var/snap/nextcloud/ | awk '{print $1}') + ${diskSize} * 2 / 10))
if [ "${emptySpace}" -lt "${spaceNeeded}" ]; then
  echo "You don't have enough space for a backup! You need to have at least ${spaceNeeded} kbs. You have ${emptySpace}."
  exit 1
fi

# Export all data.
# TODO: Modify and pass this to the export command below when we can customize the output path.
nextcloudExportsPath="/var/snap/nextcloud/common/backups"

nextcloud.export

# Compress it.
latestExportPath="${nextcloudExportsPath}/$(ls -t "${nextcloudExportsPath}" | head -1)"
tar --remove-files -czvf "/root/nextcloud_$(date +'%Y-%m-%d_%H-%M-%S').tar.gz" "${latestExportPath}"
