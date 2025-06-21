#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <output-directory>"
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

OUTPUT_DIRECTORY="$1"
DESTDIR="${OUTPUT_DIRECTORY}/root" ninja -C build install
