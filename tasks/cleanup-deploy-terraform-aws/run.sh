#!/bin/bash

set -ex

terraform_dir=$(echo $PWD/lattice-bundle-v*/terraform/aws)

pushd "$terraform_dir" >/dev/null
    terraform destroy -force || terraform destroy -force
popd >/dev/null
