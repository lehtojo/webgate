#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <data-directory> <output-directory>"
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

data_directory="$1"
output_directory="$2"

echo "Postinstalling modules from ${data_directory}..."

if [ ! -d "${data_directory}" ]; then
  echo "ERROR: Data directory ${data_directory} does not exist"
  exit 1
fi

root_directory="${output_directory}/root"

if [ ! -d "${root_directory}" ]; then
  echo "ERROR: Root directory ${root_directory} does not exist"
  exit 1
fi

for module_path in "${data_directory}"/*/; do
  [ -d "${module_path}" ] || continue
  
  module_name="$(basename "${module_path}")"
  echo "Postinstalling module: ${module_name}"
  
  install_script="${module_path}postinstall.sh"
  
  if [ -f "${install_script}" ]; then
    echo "Running postinstall for ${module_name}..."
    cd "$module_path" || exit 1
    if ! sh postinstall.sh "$output_directory"; then
      echo "ERROR: Postinstall failed for module ${module_name}"
      exit 1
    fi
    echo "Postinstall completed for ${module_name}"
  fi
done

echo "All modules postinstalled successfully."
