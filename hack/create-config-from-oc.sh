#!/usr/bin/env bash

# This script generates a new pull-secret by adding oc login credentials to the
# existing pull-secret.

DIR="/home/ibihim/Documents/area/work/red_hat/cluster/config"

# Go to the directory
pushd "$DIR" || exit 1

# Store the secret to pull-secret.json
oc registry login --to="./pull-secret.json"

# Minify the json file
jq -c < pull-secret.json > pull-secret.min.json

# Come back
popd || exit 1

