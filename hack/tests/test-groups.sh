#!/usr/bin/env bash
oc login -u system:admin
oc adm groups remove-users myadmins peterparker brucewayne
oc adm groups add-users myadmins peterparker
oc login -u peterparker -p iamspiderman
oc adm groups add-users myadmins brucewayne
sleep 120
if [ "$(kubectl get pods -A | wc -l)" -gt 200 ]; then
    echo success
else
    echo failure
fi
