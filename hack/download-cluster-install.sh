#!/usr/bin/env bash
# download openshift installer

URL=https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp-dev-preview/pre-release/openshift-install-linux.tar.gz

wget "$URL"
tar xvfz openshift-install-linux.tar.gz
rm README.md openshift-install-linux.tar.gz
printf '\n\nDownloaded: '
./openshift-install version | head -n 1 | sed 's/ /_/' | sed 's/.\///' | tee /dev/tty | xargs -i mv openshift-install bin/{}

