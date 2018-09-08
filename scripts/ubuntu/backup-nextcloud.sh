#!/usr/bin/env bash

set -eu

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run backup as root."
  exit 1
fi

# TODO: Modify and pass this to the export command below when we can customize the output path.
nextcloudExportsPath="/var/snap/nextcloud/common/backups"

nextcloud.export

latestExportPath="${nextcloudExportsPath}/$(ls -t "${nextcloudExportsPath}" | head -1)"
tar --remove-files -czvf "/root/nextcloud_$(date +'%Y-%m-%d_%H-%M-%S').tar.gz" "${latestExportPath}"
