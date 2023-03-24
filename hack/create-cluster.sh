#!/usr/bin/env bash

# This script is used to create a new cluster based on a install-config.yaml
# template.
# The cluster data is stored in a directory named after the current timestamp.
# It is assumed that the installation config template has a {{timestamp}} that
# will be replaced with the timestamp of the created directory.

set -o errexit
set -o pipefail
set -o nounset

DIR="$HOME/Documents/area/work/red_hat/cluster"
CONFIG_TEMPLATE="config/install-config.yaml"

# Define usage information
usage() {
    printf "Usage: %s [-d DIR] [-c CONFIG_TEMPLATE]\n" "$0"
    printf "       %s [--directory DIR] [--config-template CONFIG_TEMPLATE]\n\n" "$0"
    printf "Options:\n"
    printf "  -d, --directory DIR                       Specify the directory to create the cluster in. (default: %s)\n" "$DIR"
    printf "  -c, --config-template CONFIG_TEMPLATE     Specify the location of the install-config.yaml template file. (default: %s)\n" "$CONFIG_TEMPLATE"
}

# Create the directory for the cluster
create_cluster_dir() {
    local dir="$1"

    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            echo "Error: Failed to create directory: $dir" >&2
            exit 1
        }
    fi
}

# Generate the install-config.yaml file
generate_config() {
    local config_template="$1"
    local timestamp="$2"
    local config_file="$timestamp/install-config.yaml"

    sed "s/{{timestamp}}/$timestamp/g" "$config_template" > "$config_file" || {
        echo "Error: Failed to generate install-config.yaml file" >&2
        exit 1
    }

    printf 'install-config.yaml in use:\n'
    cat "$config_file"
}

# Create the OpenShift cluster
create_cluster() {
    local dir="$1"

    pushd "$dir" || {
        echo "Error: Failed to change directory to: $dir" >&2
        exit 1
    }
    openshift-install create cluster --dir="." || {
        echo "Error: Failed to create OpenShift cluster" >&2
        exit 1
    }
    popd || {
        echo "Error: Failed to change directory to: $dir" >&2
        exit 1
    }
}

# Main function
main() {
    # Parse command-line arguments
    local dir="$DIR"
    local config_template="$CONFIG_TEMPLATE"
    local timestamp
    timestamp="$(date +%s)"

    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--directory)
                dir="$2"
                shift 2
                ;;
            -c|--config-template)
                config_template="$2"
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

    # Change to the directory where the cluster directory will be created
    pushd "$dir"

    # Create the directory for the cluster
    create_cluster_dir "$timestamp"

    # Generate the install-config.yaml file
    generate_config "$config_template" "$timestamp"

    # Create the OpenShift cluster
    create_cluster "$timestamp"

    # Print completion message
    printf "Cluster created successfully in directory: %s\n" "$timestamp"

    # Change back to the original directory
    popd
}

# Run the script
main "$@"
