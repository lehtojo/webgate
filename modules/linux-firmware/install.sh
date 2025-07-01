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

if [ ! -d "${MODULE_DIRECTORY}/out" ]; then
  mkdir -p "${MODULE_DIRECTORY}/out"
  DESTDIR="${MODULE_DIRECTORY}/out" make install dedup
fi

mkdir -p "${OUTPUT_DIRECTORY}/root/lib/firmware"

# TODO: We need a nice way to select firmware
cp -r --no-dereference "${MODULE_DIRECTORY}/out/lib/firmware/amdgpu/." "${OUTPUT_DIRECTORY}/root/lib/firmware/amdgpu/"
