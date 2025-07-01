#!/bin/sh
set -eu

if [ $# -ne 1 ]; then
  echo "Usage: $0 <output-directory>" >&2
  exit 1
fi

output_directory="$1"

# We do not need header or development files in the system
if [ -n "$output_directory" ]; then
  rm -rf "${output_directory}/root/usr/include" 2>/dev/null || true
fi

mkdir -p "${output_directory}/root/dev"
mkdir -p "${output_directory}/root/proc"
mkdir -p "${output_directory}/root/sys"
mkdir -p "${output_directory}/root/tmp"
