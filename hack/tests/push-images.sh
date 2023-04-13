#!/usr/bin/env bash

for TAG in 56db222 1d6c975 ea63a03 22e8c53; do
    git checkout $TAG
    make images
    docker tag registry.svc.ci.openshift.org/ocp/4.3:oauth-apiserver quay.io/kostrows/oauth-apiserver:$TAG
    docker push quay.io/kostrows/oauth-apiserver:$TAG
done