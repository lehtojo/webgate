#!/bin/sh
set -eu

usage() {
  echo "Usage: $0 <output-directory>"
}

if [ "$#" -ne 1 ]; then
  usage
  exit 1
fi

output_directory="$1"
efi_boot_directory="${output_directory}/image/EFI/BOOT"
output_image="${output_directory}/system.img"

# UEFI expects the default bootloader to exist at "EFI/BOOT/BOOTX64.EFI"
mkdir -p "${output_directory}/image/EFI/BOOT"
cp "${output_directory}/bootloader.efi" "${efi_boot_directory}/BOOTX64.EFI"

# Compute required size for image contents with 16 MiB margin
# TODO: Check the flags
safety_margin=16
image_folder_size=$(du -sm "${output_directory}/image" | cut -f1)
total_size=$((image_folder_size + safety_margin))
echo "Image size: ${image_folder_size} MiB"

# Create and format the system image
truncate -s "${total_size}M" "${output_image}"
mkfs.vfat -F 32 "${output_image}" 1>/dev/null

# Mount image and copy files inside it
mount_directory="${output_directory}/mount"
mkdir -p "${mount_directory}"
mount -o loop "${output_image}" "${mount_directory}"
cp -r "${output_directory}/image"/* "${mount_directory}"/
sync
umount "${mount_directory}"
rmdir "${mount_directory}"

echo
echo "System image created at: out/system.img"