#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <data-directory>"
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed."
  exit 1
fi

module_directory="$(dirname "$0")"
data_directory="$1"

echo "Syncing modules to ${data_directory}..."

if [ ! -d "${data_directory}" ]; then
  echo "ERROR: Data directory ${data_directory} does not exist"
  exit 1
fi

for module_path in "${module_directory}"/*/; do
  [ -d "${module_path}" ] || continue
  
  module_name="$(basename "${module_path}")"
  config_file="${module_path}config.json"

  echo "Processing module: ${module_name}"
  
  if [ ! -f "${config_file}" ]; then
    # If the module directory does not contain a config file, copy the module directory to the data directory
    echo "INFO: No config file found for module ${module_name}"
    target_directory="${data_directory}/${module_name}"
    cp -r "${module_path}/." "${target_directory}"
    continue
  fi
  
  remote_url=$(jq -r '.remote_url // empty' "${config_file}")
  commit_hash=$(jq -r '.commit_hash // empty' "${config_file}")
  
  if [ -z "${remote_url}" ]; then
    echo "Error: Remote URL is not set"
    exit 1
  fi
  
  if [ -z "${commit_hash}" ]; then
    echo "ERROR: Commit hash is not set"
    exit 1
  fi
  
  target_directory="${data_directory}/${module_name}"
  
  if [ ! -d "${target_directory}/.git" ]; then
    if ! git clone "${remote_url}" "${target_directory}"; then
      echo "ERROR: Failed to clone ${module_name} from ${remote_url}"
      exit 1
    fi
  fi
  
  echo "Fetching updates and checking out commit ${commit_hash}..."
  cd "${target_directory}" || exit 1
  if (git fetch --quiet && git checkout --quiet "${commit_hash}"); then
    echo "Successfully checked out commit ${commit_hash} for ${module_name}"
  else
    echo "ERROR: Failed to checkout commit ${commit_hash} for ${module_name}"
    exit 1
  fi
done

echo "All modules synced successfully."