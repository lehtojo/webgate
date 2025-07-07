#!/bin/sh
set -eu

export PATH="$PATH:$PWD"

echo "Clean build might take hours"
echo "Building Chromium..."
cd ./src/
autoninja -C out/drm content_shell
echo "Chromium build completed successfully"

