#!/usr/bin/env bash

# Patch pull secret with registry token.

oc registry login --to config/pull-secret.min.json \
    && mv config/pull-secret{.min,}.json \
    && cat config/pull-secret.json | jq -c > config/pull-secret.min.json

