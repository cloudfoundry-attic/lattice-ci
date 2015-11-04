#!/bin/bash

set -e

eval $(ssh-agent)
echo "$GITHUB_SSH_KEY" > private_key.pem
chmod 0600 private_key.pem
ssh-add private_key.pem > /dev/null
rm private_key.pem

set -x

current_version=$(cat current-terraform-ami-version/number)
next_version=$(cat next-terraform-ami-version/number)
current_ami_commit=$(cat "terraform-ami-commit/ami-commit-v$current_version")
next_ami_commit=$(git -C terraform-image-changes rev-parse -q --verify HEAD)

if [[ $current_ami_commit == $next_ami_commit ]]; then
  echo -n $current_ami_commit > ami-commit-v$current_version
  echo -n $current_version > ami-version-number
  cp "terraform-ami-metadata/ami-metadata-v${current_version}.tf.json" .
  exit 0
fi

git -C terraform-image-changes submodule update --init --recursive
terraform-image-changes/terraform/build -machine-readable -var "version=$next_version" | tee build.log

tail -50 build.log | lattice-ci/tasks/build-terraform-images/parse-build-output.rb | jq . > ami-metadata-v${next_version}.tf.json
echo -n $next_ami_commit > ami-commit-v$next_version
echo -n $next_version > ami-version-number
