#!/bin/sh
set -eu

PROJECT_DIRECTORY=$(dirname "$0")
"${PROJECT_DIRECTORY}/control.sh" sync attach setup build install postinstall filesystem bootloader
sudo "${PROJECT_DIRECTORY}/scripts/image.sh" "${PROJECT_DIRECTORY}/out"
