#!/bin/bash
# Usage: sync_with_s3.sh base_path dest_path [...files]

set -eu

# set -x # Uncomment to debug this script

# Get script directory for relative paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=common_functions.sh
if ! source "${SCRIPT_DIR}/common_functions.sh"; then
  echo "::error:: Failed to source common_functions.sh"
  exit 1
fi

if [ -z "${DAGS_BUCKET_URI}" ]; then
  echo "::error:: DAGS_BUCKET_URI is not set."
  exit 1
fi

base_path=$1
dest_path=$2
shift 2

files=$*

copy_to_tmp_file "$base_path" "$files"

cmd="aws s3 sync --no-progress --delete tmp_copy/ ${DAGS_BUCKET_URI}/${dest_path}"
echo "$cmd"
$cmd
if ! $cmd; then
  echo "::error:: aws command failed: $cmd"
  echo "::error:: ERROR: $(tail -n 2 /dev/stderr)"
  exit 1
fi

rm -rf tmp_copy
