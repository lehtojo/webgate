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

# Compute required size for image contents with 32 MiB margin
safety_margin=32
image_folder_size=$(du --summarize --block-size=1M "${output_directory}/image" | cut -f1)
total_size=$((image_folder_size + safety_margin))
echo "Image size: ${image_folder_size} MiB"

# Create the system image
truncate -s "${total_size}M" "${output_image}"

# Create GPT partition table with a single FAT32 partition
fdisk "${output_image}" << EOF
g
n
1


t
1
w
EOF

# Setup loop device for the image
loop_device=$(losetup --find --show "${output_image}")
echo "Using loop device: ${loop_device}"

# Inform kernel about partition table
partprobe "${loop_device}"

# Format the first partition as FAT32
mkfs.vfat -F 32 "${loop_device}p1" 1>/dev/null

# Mount partition and copy files inside it
mount_directory="${output_directory}/mount"
mkdir -p "${mount_directory}"
mount "${loop_device}p1" "${mount_directory}"
cp -r "${output_directory}/image"/* "${mount_directory}"/
sync
umount "${mount_directory}"
rmdir "${mount_directory}"

# Detach loop device
losetup --detach "${loop_device}"

echo
echo "System image created at: out/system.img"