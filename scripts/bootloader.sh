#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <output-directory>"
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

output_directory="$1"

ukify build \
  --linux="${output_directory}/kernel.img" \
  --cmdline=@"${output_directory}/commandline.txt" \
  --initrd="${output_directory}/filesystem.cpio" \
  --output="${output_directory}/bootloader.efi"