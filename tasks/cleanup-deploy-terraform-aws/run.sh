#!/bin/bash

set -ex

pushd terraform-image-changes
  git submodule update --init
popd

pushd $PWD/deploy-terraform-aws/terraform-tmp
    terraform get -update
    terraform destroy -force || terraform destroy -force
popd
