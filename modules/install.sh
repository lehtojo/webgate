#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <data-directory> <output-directory>"
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

cleanup() {
  # Recover the old root directory in case of error
  if [ -d "${root_directory}-old" ] && [ -d "${root_directory}" ]; then
    echo "Recovering output directory..."
    rm -rf "${root_directory}"
    mv "${root_directory}-old" "${root_directory}"
    echo "Output directory recovered."
  fi
}

trap cleanup EXIT

data_directory="$1"
output_directory="$2"

echo "Installing modules from ${data_directory}..."

if [ ! -d "${data_directory}" ]; then
  echo "ERROR: Data directory ${data_directory} does not exist"
  exit 1
fi

if [ ! -d "${output_directory}" ]; then
  echo "ERROR: Output directory ${output_directory} does not exist"
  exit 1
fi

root_directory="${output_directory}/root"

# If the old root directory exists, rename it for reversibility
if [ -d "${root_directory}" ]; then
  mv "${root_directory}" "${root_directory}-old"
fi

mkdir -p "${root_directory}"

for module_path in "${data_directory}"/*/; do
  [ -d "${module_path}" ] || continue
  
  module_name="$(basename "${module_path}")"
  echo "Installing module: ${module_name}"
  
  install_script="${module_path}install.sh"
  
  if [ -f "${install_script}" ]; then
    echo "Running install for ${module_name}..."
    cd "${module_path}" || exit 1
    if ! sh install.sh "${output_directory}"; then
      echo "ERROR: Install failed for module ${module_name}"
      exit 1
    fi
    echo "Install completed for ${module_name}"
  else
    echo "INFO: No install script found for module ${module_name}"
  fi
done

# Remove the old root directory if it exists
if [ -d "${root_directory}-old" ]; then
  rm -rf "${root_directory}-old"
fi

echo "All modules installed successfully."
