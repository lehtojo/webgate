#!/bin/sh
set -eu

export PATH="$PATH:$PWD"

if ! command -v gclient >/dev/null 2>&1; then
  echo "ERROR: Failed to find depot_tools"
  exit 1
fi

echo "Syncing Chromium source code..."
run_hooks="false"

if [ ! -d "./src" ]; then
  ./fetch --nohooks --no-history chromium
  run_hooks="true"
fi

cd ./src/

if [ ! -f "../commit.txt" ]; then
  echo "ERROR: Failed to find Chromium commit lock file"
  exit 1
fi

commit_hash=$(cat "../commit.txt" | tr -d '\n')

if ! git checkout "$commit_hash"; then
  echo "ERROR: Failed to checkout to commit $commit_hash"
  echo "Make sure the commit hash is valid and exists in the repository"
  exit 1
fi

echo "Updating dependencies and syncing to commit $commit_hash..."
gclient sync --nohooks --no-history

# Patch the Chromium source code if it has not been patched
if git diff --quiet; then
  echo "Patching Chromium source code..."
  if ! git apply "../chromium.patch"; then
    echo "ERROR: Failed to apply patch"
    exit 1
  fi
fi

if [ "$run_hooks" = "true" ]; then
  echo "Running Chromium hooks..."
  gclient runhooks
else
  echo "Skipping Chromium hooks as they have already been run"
fi

echo "Generating Chromium build files..."

if [ -f "../args.gn" ]; then
  gn gen out/drm --args="$(cat "../args.gn")"
else
  echo "ERROR: Failed to find Chromium build configuration"
  exit 1
fi
