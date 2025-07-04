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

cp "${MODULE_DIRECTORY}"/target/*-linux-musl/release/init "${OUTPUT_DIRECTORY}/root/"
