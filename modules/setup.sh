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

echo "Setting up modules in ${data_directory}..."

if [ ! -d "${data_directory}" ]; then
  echo "ERROR: Data directory ${data_directory} does not exist"
  exit 1
fi

for module_path in "${data_directory}"/*/; do
  [ -d "${module_path}" ] || continue
  
  module_name="$(basename "${module_path}")"
  echo "Setting up module: ${module_name}"
  
  setup_script="${module_path}setup.sh"
  
  if [ -f "${setup_script}" ]; then
    echo "Running setup for ${module_name}..."
    cd "${module_path}" || exit 1
    if ! sh setup.sh; then
      echo "ERROR: Setup failed for module ${module_name}"
      exit 1
    fi
    echo "Setup completed for ${module_name}"
  else
    echo "INFO: No setup script found for module ${module_name}"
  fi
done

echo "All modules setup completed successfully."
