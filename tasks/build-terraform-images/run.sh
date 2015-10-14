#!/bin/bash

set -ex

current_version=$(cat current-terraform-ami-version/number)
next_version=$(cat next-terraform-ami-version/number)
current_ami_commit=$(cat "terraform-ami-commit/ami-commit-v$current_version")
next_ami_commit=$(git -C terraform-image-changes rev-parse -q --verify HEAD)

mkdir updated-terraform-ami-version 
if [[ $current_ami_commit == $next_ami_commit ]]; then
  echo $current_version > updated-terraform-ami-version/number
  exit 0
fi

lattice-release/terraform/build -machine-readable -var "version=$next_version" | tee build.log

tail -50 build.log | ./lattice-ci/tasks/build-terraform-images/parse_build_output.rb > ami-metadata-v${next_version}.tf.json
echo $next_ami_commit > ami-commit-v$next_version
echo $next_version > updated-terraform-ami-version/number

