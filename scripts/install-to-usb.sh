#!/bin/sh
set -eu

script_directory=$(dirname "$(readlink -f "$0")")
exec "$script_directory/install-to-device.sh" "/dev/sd*" "$@"
