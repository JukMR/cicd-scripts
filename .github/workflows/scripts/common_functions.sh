#!/bin/bash

# Function to copy file with modified path
copy_with_modified_path() {
    local file="$1"
    local base_path="$2"
    local tmp_dir="$3"

    local filename
    local directory
    local target_dir

    filename=$(basename "$file")
    directory=$(dirname "$file")

    # Remove the base folder (banking_dags or general_dags and remove any leading /)
    target_dir=$(echo "$directory" | sed "s|${base_path}||" | sed 's|^/||')

    if [[ -n "$target_dir" ]]; then
        mkdir -p "${tmp_dir}/${target_dir}"
        # Remove base folder
        echo "Copying $file to ${tmp_dir}/${target_dir}/${filename}"
        cp -r "$file" "${tmp_dir}/${target_dir}/${filename}"

    else
        mkdir -p "${tmp_dir}"
        # Don't add main folder if empty
        echo "Copying $file to ${tmp_dir}/${filename}"
        cp "$file" "${tmp_dir}/${filename}"
    fi
}

copy_to_tmp_file() {

    base_path=$1
    files=$*

    # Create tmp directory
    mkdir tmp_copy/

    for file in $files; do
        echo "checking $file"
        if [[ ! -e "$file" ]]; then
            echo "::error:: File does not exist: $file"
            exit 1
        fi
        if [[ "$file" != ${base_path}/* ]]; then
            echo "::warning:: File $file will not get deployed with $base_path"
        else
            copy_with_modified_path "$file" "$base_path" "tmp_copy"
        fi
    done

    tree tmp_copy/
}
