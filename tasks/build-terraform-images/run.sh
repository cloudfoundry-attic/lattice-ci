#!/bin/bash

set -ex

current_version=$(cat current-terraform-ami-version/number)
next_version=$(cat next-terraform-ami-version/number)
current_ami_commit=$(cat "terraform-ami-commit/ami-commit-v$current_version")
next_ami_commit=$(git -C terraform-image-changes rev-parse -q --verify HEAD)

if [[ $current_ami_commit == $next_ami_commit ]]; then
  echo $current_version > ami-version-number
  exit 0
fi


mkdir -p $HOME/.ssh
ssh-keyscan github.com >> $HOME/.ssh/known_hosts
pushd terraform-image-changes > /dev/null
  git submodule update --init --recursive
popd > /dev/null

terraform-image-changes/terraform/build -machine-readable -var "version=$next_version" | tee build.log

tail -50 build.log | ./lattice-ci/tasks/build-terraform-images/parse-build-output.rb > ami-metadata-v${next_version}.tf.json
echo $next_ami_commit > ami-commit-v$next_version
echo $next_version > ami-version-number

