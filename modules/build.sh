#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <data-directory>"
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

data_directory="$1"

echo "Building modules in ${data_directory}..."

if [ ! -d "${data_directory}" ]; then
  echo "ERROR: Data directory ${data_directory} does not exist"
  exit 1
fi

for module_path in "${data_directory}"/*/; do
  [ -d "${module_path}" ] || continue
  
  module_name="$(basename "${module_path}")"
  echo "Building module: ${module_name}"
  
  build_script="${module_path}build.sh"
  
  if [ -f "${build_script}" ]; then
    echo "Running build for ${module_name}..."
    cd "${module_path}" || exit 1
    if ! sh build.sh; then
      echo "ERROR: Build failed for module ${module_name}"
      exit 1
    fi
    echo "Build completed for ${module_name}"
  else
    echo "INFO: No build script found for module ${module_name}"
  fi
done

echo "All modules built successfully."
