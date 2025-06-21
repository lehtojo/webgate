#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <data-directory>"
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

module_directory="$(dirname "$0")"
data_directory="$1"

echo "Applying patches to ${data_directory}..."
cp -r "${module_directory}/." "${data_directory}/"
echo "Patches applied successfully."
