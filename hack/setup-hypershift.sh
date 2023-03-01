#!/usr/bin/env bash

###############################################################################
#
# Setup of Hypershift on an OpenShift clusters.
# Assumes:
# - you are in the hypershift repository
# - you want to debug control-plane-operator
#
###############################################################################

AWS_CREDS="$HOME/.aws/credentials"
BASE_DOMAIN="kostrows-1668517527.group-b.devcluster.openshift.com"
BUCKET_NAME="kostrows-bucket"
CLUSTER_NAME="kostrows-1668517527"
IMAGE="quay.io/kostrows/control-plane-operator:latest"
NAMESPACE="clusters-$CLUSTER_NAME"
PULL_SECRET="$HOME/.tmp/kube/pull-secret.min.json"
REGION="us-east-1"

# Create Bucket
aws s3api \
    create-bucket \
    --acl public-read \
    --bucket "$BUCKET_NAME" \
    --region "$REGION"

# Createa route53
aws route53 \
    create-hosted-zone \
    --name "$BASE_DOMAIN" \
    --caller-reference "$CLUSTER_NAME"

# Build local binaries
make build

# Setup deployment
go run . install \
  --oidc-storage-provider-s3-bucket-name=$BUCKET_NAME \
  --oidc-storage-provider-s3-region=$REGION \
  --oidc-storage-provider-s3-credentials=$AWS_CREDS

# Create cluster
./bin/hypershift create cluster aws \
  --name "$CLUSTER_NAME" \
  --node-pool-replicas=3 \
  --base-domain "$BASE_DOMAIN" \
  --pull-secret "$PULL_SECRET" \
  --aws-creds "$AWS_CREDS" \
  --region "$REGION" \
  --generate-ssh \
  --annotations hypershift.openshift.io/debug-deployments=control-plane-operator

# Build image
podman build -t "$IMAGE" -f Dockerfile.control-plane .

# Run control-plane-operator locally
oc debug \
    --namespace "$NAMESPACE" deployments/control-plane-operator \
    --image "$IMAGE" \
    -- /usr/bin/control-plane-operator run
