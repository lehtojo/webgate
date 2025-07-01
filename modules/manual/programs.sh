#/bin/sh
set -eu

if [ $# -ne 1 ]; then
  echo "Usage: $0 <output-directory>" >&2
  exit 1
fi

output_directory="$1"

cp /usr/bin/mkdir "${output_directory}/root/usr/bin/"
cp /usr/bin/mount "${output_directory}/root/usr/bin/"
cp /usr/bin/sync "${output_directory}/root/usr/bin/"
