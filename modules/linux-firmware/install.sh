#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <output-directory>"
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

MODULE_DIRECTORY=$(dirname "$0")
OUTPUT_DIRECTORY="$1"

# TODO: We need a nice way to select firmware
mkdir -p "${OUTPUT_DIRECTORY}/root/lib/firmware/amdgpu"
cp -r "${MODULE_DIRECTORY}/amdgpu/." "${OUTPUT_DIRECTORY}/root/lib/firmware/amdgpu"