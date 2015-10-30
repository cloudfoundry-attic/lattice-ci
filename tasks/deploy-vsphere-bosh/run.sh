#!/bin/bash

set -ex

cp lattice-ci/tasks/deploy-vsphere-bosh/manifest.yml .

sed -i "s/VCENTER-ADDRESS/$VCENTER_ADDRESS/g" manifest.yml
sed -i "s/VCENTER-USERNAME/$VCENTER_USERNAME/g" manifest.yml
sed -i "s/VCENTER-PASSWORD/$VCENTER_PASSWORD/g" manifest.yml

bosh-init deploy manifest.yml
