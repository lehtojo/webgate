#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <command-1> [command-2] [command-3] ..."
  echo ""
  echo "Available commands:"
  echo "  sync       - Sync modules to data directory"
  echo "  attach     - Attach modules"
  echo "  setup      - Setup modules"
  echo "  build      - Build modules"
  echo "  install    - Install modules"
  echo "  filesystem - Create filesystem"
  echo "  bootloader - Setup bootloader"
  echo "  image      - Create image"
  echo ""
  echo "Multiple commands can be specified and will be executed in sequence."
}

if [ "$#" -eq 0 ]; then
  usage
  exit 1
fi

modules_directory="/workspace/modules"
scripts_directory="/workspace/scripts"
data_directory="/workspace/data"
out_directory="/workspace/out"

execute_command() {
  command="$1"
  
  case "$command" in
    sync)
      echo "==> Executing: sync"
      "${modules_directory}/sync.sh" "${data_directory}"
      ;;
    attach)
      echo "==> Executing: attach"
      "${modules_directory}/attach.sh" "${data_directory}"
      ;;
    setup)
      echo "==> Executing: setup"
      "${modules_directory}/setup.sh" "${data_directory}"
      ;;
    build)
      echo "==> Executing: build"
      "${modules_directory}/build.sh" "${data_directory}"
      ;;
    install)
      echo "==> Executing: install"
      "${modules_directory}/install.sh" "${data_directory}" "${out_directory}"
      ;;
    filesystem)
      echo "==> Executing: filesystem"
      "${scripts_directory}/filesystem.sh" "${out_directory}"
      ;;
    bootloader)
      echo "==> Executing: bootloader"
      "${scripts_directory}/bootloader.sh" "${out_directory}"
      ;;
    image)
      echo "==> Executing: image"
      "${scripts_directory}/image.sh" "${out_directory}"
      ;;
    *)
      echo "ERROR: Unknown command: $command"
      return 1
      ;;
  esac
}

for command in "$@"; do
  execute_command "$command"
  if [ $? -ne 0 ]; then
    echo "ERROR: Command '$command' failed. Terminating."
    exit 1
  fi
done

echo "==> Done."
