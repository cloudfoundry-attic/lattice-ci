#!/bin/bash

set -e

bosh -t "$BOSH_TARGET" login admin "$BOSH_PASSWORD"

set -x

BOSH_UUID=$(bosh -n --color -t "$BOSH_TARGET" status --uuid)
FORMATTED_VSPHERE_WORKER_PRIVATE_KEY=$(echo -n "$VSPHERE_WORKER_PRIVATE_KEY" | perl -p -e 's/\n/\\\\n/g')

cp lattice-ci/tasks/generate-vsphere-worker-manifest/manifest.yml .

sed -i "s/BOSH-UUID/$BOSH_UUID/g" manifest.yml
sed -i "s%TSA-PUBLIC-KEY%$CONCOURSE_TSA_PUBLIC_KEY%g" manifest.yml
sed -i "s%WORKER-PRIVATE-KEY%\"$FORMATTED_VSPHERE_WORKER_PRIVATE_KEY\"%g" manifest.yml
