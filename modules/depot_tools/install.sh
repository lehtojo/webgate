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
TARGET_DIR="${OUTPUT_DIRECTORY}/root/usr/bin/ui"

mkdir -p "${TARGET_DIR}"

# Copy any shared libraries that may be needed
find ./src/out/drm -name "*.so" -exec cp {} "${TARGET_DIR}/" \; 2>/dev/null

# Copy any package that may be needed
find ./src/out/drm -name "*.pak" -exec cp {} "${TARGET_DIR}/" \; 2>/dev/null

# Copy any snapshot files that may be needed
find ./src/out/drm -name "snapshot_*" -exec cp {} "${TARGET_DIR}/" \; 2>/dev/null

# Copy Unicode character and locale data for Chromium
cp ./src/out/drm/icudtl.dat "${TARGET_DIR}/" 2>/dev/null

# Copy the Chromium binary
cp ./src/out/drm/content_shell "${TARGET_DIR}/" 2>/dev/null

# Make Chromium executable
chmod +x "${TARGET_DIR}/content_shell"
