#!/usr/bin/env bash

# This script is used to create a new cluster based on a install-config.yaml template.

NEW_CLUSTER="$(date +%s)"
CONFIG_TEMPLATE="config/cluster/install-config.yaml"
DIR="$HOME/Documents/resources/red_hat/cluster"
OLD_CLUSTER=$(fd '\d{10}' --max-depth 1 "$DIR")

pushd "$OLD_CLUSTER" \
    && openshift-install destroy cluster

popd && pushd "$DIR" \
    && mv "$OLD_CLUSTER" ./archive \
    && mkdir "$NEW_CLUSTER" \
    && sed "s/{{timestamp}}/$NEW_CLUSTER/g" "$CONFIG_TEMPLATE" > "$NEW_CLUSTER/install-config.yaml" \
    && openshift-install create cluster --dir="$NEW_CLUSTER" \
    && popd || exit
