#!/bin/sh
set -eu

echo "Clean build might take hours"
echo "Building Chromium..."
cd ./src/
autoninja -C out/drm content_shell
echo "Chromium build completed successfully"

