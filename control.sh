#!/bin/sh
set -eu

if ! command -v docker > /dev/null; then
  echo "Docker is not installed. Please install Docker to use this script."
  exit 1
fi

PROJECT_DIRECTORY=$(realpath "$(dirname "$0")")
PROJECT_NAME=$(basename "$PROJECT_DIRECTORY")
CONTAINER_NAME="$PROJECT_NAME"
IMAGE_NAME="${CONTAINER_NAME}:latest"

# Build the image if it does not exist
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
  echo "Building Docker image $IMAGE_NAME..."
  docker build -t "$IMAGE_NAME" "$PROJECT_DIRECTORY"
fi

# Ensure the data and output directories exist
mkdir -p "${PROJECT_DIRECTORY}/data"
mkdir -p "${PROJECT_DIRECTORY}/out"

docker run --rm --privileged \
  --name "$CONTAINER_NAME" \
  -v "${PROJECT_DIRECTORY}/data:/workspace/data" \
  -v "${PROJECT_DIRECTORY}/modules:/workspace/modules" \
  -v "${PROJECT_DIRECTORY}/out:/workspace/out" \
  -v "${PROJECT_DIRECTORY}/scripts:/workspace/scripts" \
  "$IMAGE_NAME" \
  "$@"
