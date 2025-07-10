#!/bin/sh
set -eu

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RESET='\033[0m'

usage() {
  echo "Usage: $0 <device-pattern> [options]"
  echo ""
  echo "Arguments:"
  echo "  device-pattern    Device pattern to search for (e.g., /dev/sda, /dev/sd*, /dev/loop*)"
  echo ""
  echo "Options:"
  echo "  -d, --device     Explicitly specify the device to use"
  echo "  -f, --force      Skip the warning delay"
  echo "  -i, --image      Specify custom image file (default: out/system.img)"
  echo "  -h, --help       Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 /dev/sda                         # Install to /dev/sda with 10s warning"
  echo "  $0 /dev/sd* --force                 # Search for /dev/sd* devices (USBs most likely), skip the warning"
  echo "  $0 /dev/sd* --device /dev/sdb       # Install to explicitly specified /dev/sdb"
  echo "  $0 /dev/loop* --image image.img     # Install 'image.img' to a loop device"
}

# Parse arguments:
skip_warning=false
explicit_device=""
image_file=""
device_pattern=""

while [ $# -gt 0 ]; do
  case "$1" in
    -d|--device)
      if [ $# -lt 2 ]; then
        echo "ERROR: Expected device argument after '--device'" >&2
        exit 1
      fi
      explicit_device="$2"
      shift 2
      ;;
    -f|--force)
      skip_warning=true
      shift
      ;;
    -i|--image)
      if [ $# -lt 2 ]; then
        echo "ERROR: Expected image file argument after '--image'" >&2
        exit 1
      fi
      image_file="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      echo "ERROR: Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [ -z "$device_pattern" ]; then
        device_pattern="$1"
      else
        echo "ERROR: Multiple device patterns specified" >&2
        usage >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$device_pattern" ] && [ -z "$explicit_device" ]; then
  echo "ERROR: Device pattern is required without explicit device" >&2
  usage >&2
  exit 1
fi

# Set default image file if not specified
if [ -z "$image_file" ]; then
  script_directory=$(dirname "$(readlink -f "$0")")
  project_directory="$(dirname "$script_directory")"
  image_file="${project_directory}/out/system.img"
fi

if [ ! -f "$image_file" ]; then
  echo "ERROR: Image file '$image_file' does not exist" >&2
  echo "Make sure to build the system" >&2
  exit 1
fi

if [ "$(id --user)" -ne 0 ]; then
  echo "ERROR: This script must be run as root" >&2
  exit 1
fi

find_disk_devices() {
  pattern="$1"
  devices=""
  
  for device in $pattern; do
    if [ -b "$device" ]; then
      device_name=$(basename "$device")
      
      # Skip partition devices, we want whole devices
      if [ -f "/sys/class/block/${device_name}/partition" ]; then
        continue
      fi

      devices="$devices $device"
    fi
  done

  echo "$devices" | tr ' ' '\n' | grep -v '^$' || true
}

# Determine target device:
if [ -n "$explicit_device" ]; then
  if [ ! -b "$explicit_device" ]; then
    echo "ERROR: Device '$explicit_device' is not a valid block device" >&2
    exit 1
  fi
  target_device="$explicit_device"
else
  # Find devices matching the pattern
  matching_devices=$(find_disk_devices "$device_pattern")
  device_count=$(echo "$matching_devices" | wc --lines)
  
  if [ -z "$matching_devices" ]; then
    echo "ERROR: No devices found matching pattern '$device_pattern'" >&2
    exit 1
  elif [ "$device_count" -eq 1 ]; then
    # Single device found
    target_device="$matching_devices"
  else
    # Multiple devices found, ask the user to specify which one
    echo "Multiple devices found matching pattern '$device_pattern':"
    echo "$matching_devices"
    echo "Specify the target device using --device"
    exit 1
  fi
fi

echo
echo "Installing to device: $target_device"
printf "${YELLOW}WARNING: This will completely overwrite all data on the device${RESET}\n"
echo

if [ "$skip_warning" = false ]; then
  echo "Use '--force' to skip the following warning."
  for i in 10 9 8 7 6 5 4 3 2 1; do
    printf "\r${GREEN}> Installing in %d second(s) (Press Ctrl+C to cancel)...${RESET}" "$i"
    sleep 1
  done
  echo
  echo
fi

# Display a nice progress bar if possible
if command -v pv >/dev/null 2>&1; then
  image_size=$(stat --format=%s "$image_file")
  pv --progress --timer --eta --rate --bytes --size "$image_size" "$image_file" \
    | dd of="$target_device" bs=1M oflag=sync 2>/dev/null
else
  dd if="$image_file" of="$target_device" bs=1M oflag=sync status=progress 2>&1
fi