#!/bin/sh
set -eu

if [ $# -ne 1 ]; then
  echo "Usage: $0 <output-directory>" >&2
  exit 1
fi

module_directory=$(dirname "$0")
output_directory="$1"
root_directory="${output_directory}/root"

# Remove temporary files once we exit
trap "rm -f '$module_directory'/*.tmp" EXIT

# Configure the library search path so that the linker finds our libraries
# before the system libraries. This way we can determine external dependencies.
export LD_LIBRARY_PATH="${root_directory}/usr/lib/x86_64-linux-gnu/:${LD_LIBRARY_PATH:-}"

# Find all dynamic libraries in the "initrd" root directory.
# Collect the dependencies of the dynamic libraries into a single file.
unprocessed_dependency_list="${module_directory}/dependencies.unprocessed.tmp"

echo "Scanning for external library dependencies in root directory..."

find "$root_directory" -executable -name "*" -type f | while read -r library_path; do
  echo "Scanning dependencies for: ${library_path}"
  LD_LIBRARY_PATH="$LD_LIBRARY_PATH" ldd "$library_path" 2>/dev/null
done | grep -E '\s+\S+\s+=>\s+\S+' >> "$unprocessed_dependency_list" || true

# Remove the load address from the end.
# Before:
#     libc.so.6 => /usr/lib/libc.so.6 (0xdead000000000000)
# After:
#     libc.so.6 => /usr/lib/libc.so.6
sed -i 's/ (0x[0-9a-fA-F]\{16\})$//' "$unprocessed_dependency_list"

# Filter out duplicate rows and sort for deterministic and minimal output
dependency_list="${module_directory}/dependencies.tmp"

sort "$unprocessed_dependency_list" | uniq > "$dependency_list"
echo "Number of dependencies: $(wc --lines < "$dependency_list")"
echo "Dependencies:"
cat "$dependency_list"

# If we can not find some dependency, there is not much we can do
MISSING_DEPENDENCY_MARKER="not found"
if grep -q "$MISSING_DEPENDENCY_MARKER" "$dependency_list"; then
  echo "ERROR: Failed to find dependency." >&2
  echo "Missing dependencies:" >&2
  grep "$MISSING_DEPENDENCY_MARKER" "$dependency_list" >&2
  exit 1
fi

# If there is a locked dependency list, compare the current dependency list against it.
# In case of a mismatch, exit with an error.
locked_dependency_list="${module_directory}/dependencies"
if [ -f "$locked_dependency_list" ]; then
  if ! cmp -s "$dependency_list" "$locked_dependency_list"; then
    echo "ERROR: Dependency lists have changed." >&2
    echo "Expected dependencies:" >&2
    cat "$locked_dependency_list" >&2
    echo "" >&2
    echo "Actual dependencies:" >&2
    cat "$dependency_list" >&2
    cp "$dependency_list" "${module_directory}/dependencies.new"
    exit 1
  fi

  echo "Dependency list matches the locked version. No changes detected."
else
  echo "Saving dependency list to locked version: $locked_dependency_list"
  cp "$dependency_list" "$locked_dependency_list"
fi

echo "Copying external dependencies..."

while IFS= read -r dependency_line; do
  # Extract library path for the dependency.
  # Example:
  #     libc.so.6 => /usr/lib/libc.so.6 (0xdead000000000000)
  # Output:
  # /usr/lib/libc.so.6
  dependency_path=$(echo "$dependency_line" | sed -n 's/.*=> \([^ ]*\).*/\1/p')

  if [ -z "$dependency_path" ]; then
    echo "ERROR: Failed to extract dependency path from line: ${dependency_line}" >&2
    exit 1
  fi
  
  case "$dependency_path" in
    "$root_directory"/*) 
      # Library is already inside root directory, we can skip it
      ;;
    *)
      # Library is outside root directory, we need to copy it inside
      # Extract the general library name without version numbers (e.g., libc.so.6.1 -> libc.so).
      # We need the general name for copying the whole versioning chain.
      library_name=$(basename "$dependency_path")
      library_general_name=$(echo "$library_name" | sed 's/\.so\..*/.so/')

      library_directory=$(dirname "$dependency_path")
      destination_directory="$root_directory/usr/lib"
      mkdir -p "$destination_directory"

      echo "Copying: ${library_directory}/${library_general_name}* -> ${destination_directory}/"
      cp -a -P "${library_directory}/${library_general_name}"* "${destination_directory}/" 2>/dev/null
    ;;
  esac
done < "$dependency_list"

# Copy the runtime linker as an exception
mkdir -p "${root_directory}/lib64"
cp -a /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 "${root_directory}/lib64/"

echo "All external dependencies copied successfully."
