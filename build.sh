#!/bin/sh
PROJECT_DIRECTORY=$(dirname "$0")
"${PROJECT_DIRECTORY}/control.sh" sync attach setup build install extra filesystem bootloader image
