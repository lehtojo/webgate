#!/bin/sh
set -eu

if [ $# -ne 1 ]; then
  echo "Usage: $0 <output-directory>" >&2
  exit 1
fi

output_directory="$1"

mkdir -p "${output_directory}/root/usr/share/fonts"
mkdir -p "${output_directory}/root/etc/fonts"

cp -r /usr/share/fonts/. "${output_directory}/root/usr/share/fonts"
cp -r /etc/fonts/. "${output_directory}/root/etc/fonts"
