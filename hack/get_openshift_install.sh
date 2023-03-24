#!/usr/bin/env bash

URL="https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/stable/openshift-install-linux.tar.gz"
TARGZ="openshift-install-linux.tar.gz"
BIN="openshift-install"
DIR="$HOME/Documents/area/work/red_hat/cluster/bin"

pushd "$DIR" && \
    wget "$URL" \
    && rm "$BIN" \
    && tar xvfz "$TARGZ" && rm README.md "$TARGZ"

NEW_NAME=$(./$BIN version | head -n 1 | sed -e 's/ /_/' -e 's/.\///')
mv "$BIN" "$NEW_NAME" \
    && ln -s "$NEW_NAME" "$BIN" \
    && popd || exit
