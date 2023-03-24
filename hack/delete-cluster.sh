#!/usr/bin/env bash

# This script is used to delete an existing openshift cluster.

# Set recommended options for shell scripts
set -o errexit
set -o pipefail
set -o nounset

DIR="$HOME/Documents/area/work/red_hat/cluster"

# Define usage information
usage() {
    printf "Usage: %s [-d DIR]\n" "$0"
    printf "       %s [--directory DIR]\n\n" "$0"
    printf "Options:\n"
    printf "  -d, --directory DIR  Specify the directory to search for timestamp folder. (default: %s)\n" "$DIR"
}

# Check if fd is installed
check_fd() {
    if ! command -v fd &>/dev/null; then
        echo "Error: 'fd' command not found. Please install it before running this script." >&2
        exit 1
    fi
}

# Check if openshift-install is installed
check_openshift_install() {
    if ! command -v openshift-install &>/dev/null; then
        echo "Error: 'openshift-install' command not found. Please install it before running this script." >&2
        exit 1
    fi
}

# Delete the cluster
delete_cluster() {
    local cluster_dir="$1"

    printf "Deleting old cluster: %s\n" "$cluster_dir"
    pushd "$cluster_dir" \
        && [[ "$(ls)" ]] \
        && openshift-install destroy cluster
    popd
}

# Archive cluster directory
archive_cluster() {
    local cluster_dir="$1"

    printf "Archiving old cluster: %s\n" "$cluster_dir"
    mkdir -p "$DIR/archive"
    mv "$cluster_dir" "$DIR/archive"
}

# Main function
main() {
    # Parse command-line arguments
    local dir="$DIR"
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--directory)
                dir="$2"
                shift 2
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                printf "Error: Unknown option: %s\n" "$1" >&2
                usage
                exit 1
                ;;
        esac
    done

    # Check if fd and openshift-install are installed
    check_fd
    check_openshift_install

    # Find old cluster directory
    local old_cluster
    old_cluster="$(fd '\d{10}' --max-depth 1 "$dir")"

    # Delete old cluster if found
    if [[ -n "$old_cluster" ]]; then
        while read -r cluster; do
            delete_cluster "$cluster"
            archive_cluster "$cluster"
        done <<< "$old_cluster"
    else
        printf "No old cluster found.\n"
    fi
}

# Run the script
main "$@"

