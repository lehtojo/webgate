#!/bin/sh
set -eu

if [ $# -ne 1 ]; then
  echo "Usage: $0 <output-directory>" >&2
  exit 1
fi

module_directory=$(dirname "$0")
output_directory="$1"

# TODO: Remove once fixed
mkdir -p "${output_directory}/root/lib/x86_64-linux-gnu/"
cp /lib/x86_64-linux-gnu/libelf-* "${output_directory}/root/usr/lib/"

"${module_directory}/fonts.sh" "$output_directory"
"${module_directory}/programs.sh" "$output_directory"
"${module_directory}/directories.sh" "$output_directory"

"${module_directory}/dependencies.sh" "$output_directory"
