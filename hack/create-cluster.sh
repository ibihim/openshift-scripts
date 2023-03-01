#!/usr/bin/env bash

# CLUSTER CREATE
WORKDIR=$HOME/Documents/resources/work/red_hat/cluster
TIMESTAMP=$(now)
FOLDER_NAME=$TIMESTAMP-cluster
wl-copy $TIMESTAMP

cd $WORKDIR

mkdir -p "$WORKDIR/$FOLDER_NAME/logs"

$WORKDIR/openshift-install-4.10.5 create cluster --dir $FOLDER_NAME create cluster
