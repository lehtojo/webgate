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
extra_directory="/workspace/extra"

if [ ! -d "$extra_directory" ]; then
  echo "WARNING: Extra directory '$extra_directory' does not exist. Nothing to copy."
  exit 0
fi

root_directory="${output_directory}/root"

if [ ! -d "$root_directory" ]; then
  echo "ERROR: Root directory '$root_directory' does not exist."
  exit 1
fi

echo "Copying files from '$extra_directory' to '$root_directory'..."
cp --no-dereference --recursive "$extra_directory/." "$root_directory/"
