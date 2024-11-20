#!/bin/bash
# Usage: rm_from_s3.sh [-r] [...files]

set -eu

# set -x # Uncomment to debug this script

# Parse flags
recursive=false
while getopts "r" opt; do
  case $opt in
  r) recursive=true ;;
  *)
    echo "Usage: $0 [-r] [...files]" >&2
    exit 1
    ;;
  esac
done
shift $((OPTIND - 1))

if [ -z "${DAGS_BUCKET_URI}" ]; then
  echo "::error:: DAGS_BUCKET_URI is not set."
  exit 1
fi

if [ $# -eq 0 ]; then
  echo "No file to remove on rm_from_s3.sh."
  exit 0
fi

files=$*
for file in $files; do
  # Add -r flag if recursive is true
  if [ "$recursive" = true ]; then
    cmd="aws s3 rm --recursive $DAGS_BUCKET_URI/$file"
  else
    cmd="aws s3 rm $DAGS_BUCKET_URI/$file"
  fi

  echo "$cmd"
  if ! $cmd; then
    echo "::error:: aws command failed: $cmd"
    echo "::error:: ERROR: $(tail -n 2 /dev/stderr)"
    exit 1
  fi
done
