#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <output-directory>"
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

# TODO: Be consistent with capitalization
output_directory="$1"
root_directory="${output_directory}/root"

if [ ! -d "$root_directory" ]; then
  echo "ERROR: The specified output directory does not contain a 'root' directory."
  exit 1
fi

# Change to the root directory and ensure we return to the original working directory
old_working_directory="$(pwd)"
trap "cd '$old_working_directory'" EXIT
cd "$root_directory"

# Package the root directory into an "initrd"
find . | cpio -H newc -o > "${output_directory}/filesystem.cpio"
