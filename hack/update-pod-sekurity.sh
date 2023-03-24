#!/usr/bin/env bash

# Define default values for namespace and level
NAMESPACE="p0t-sekurity"
LEVEL="restricted"
DRY_RUN=""

# Define usage information
usage() {
    printf "Usage: %s [-n NAMESPACE] [-l LEVEL] [-d]\n" "$0"
    printf "       %s [--namespace NAMESPACE] [--level LEVEL] [--dry-run]\n\n" "$0"
    printf "Options:\n"
    printf "  -n, --namespace NAMESPACE  Specify the namespace (default: %s)\n" "$NAMESPACE"
    printf "  -l, --level LEVEL          Specify the level (default: %s)\n" "$LEVEL"
    printf "  -d, --dry-run              Specify if it should be a server dry-run (disabled)\n\n"
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--namespace)
            NAMESPACE="$2"
            shift
            shift
            ;;
        -l|--level)
            LEVEL="$2"
            shift
            shift
            ;;
        -d|--dry-run)
            DRY_RUN="--dry-run=server"
            shift
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

# Disable the pod security label sync
kubectl label namespace "$NAMESPACE" "security.openshift.io/scc.podSecurityLabelSync=false" --overwrite $DRY_RUN

# Set the pod security level
kubectl label namespace "$NAMESPACE" "pod-security.kubernetes.io/enforce=$LEVEL" --overwrite $DRY_RUN
kubectl label namespace "$NAMESPACE" "pod-security.kubernetes.io/audit=$LEVEL" --overwrite $DRY_RUN
kubectl label namespace "$NAMESPACE" "pod-security.kubernetes.io/warn=$LEVEL" --overwrite $DRY_RUN

