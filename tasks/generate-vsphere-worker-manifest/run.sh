#!/bin/bash

set -ex

FORMATTED_VSPHERE_WORKER_PRIVATE_KEY=$(echo -n "$VSPHERE_WORKER_PRIVATE_KEY" | perl -p -e 's/\n/\\\\n/g')

cp lattice-ci/tasks/generate-vsphere-worker-manifest/manifest.yml .

sed -i "s%TSA-PUBLIC-KEY%$CONCOURSE_TSA_PUBLIC_KEY%g" manifest.yml
sed -i "s%WORKER-PRIVATE-KEY%\"$FORMATTED_VSPHERE_WORKER_PRIVATE_KEY\"%g" manifest.yml
sed -i "s/VCENTER-ADDRESS/$VCENTER_ADDRESS/g" manifest.yml
sed -i "s/VCENTER-USERNAME/$VCENTER_USERNAME/g" manifest.yml
sed -i "s/VCENTER-PASSWORD/$VCENTER_PASSWORD/g" manifest.yml
