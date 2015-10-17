#!/bin/bash

set -ex

export AWS_SSH_PRIVATE_KEY_PATH=$PWD/key.pem
echo "$AWS_SSH_PRIVATE_KEY" > "$AWS_SSH_PRIVATE_KEY_PATH"

pushd deploy-vagrant-aws/lattice-bundle-v*/vagrant >/dev/null
  vagrant destroy -f
popd >/dev/null
