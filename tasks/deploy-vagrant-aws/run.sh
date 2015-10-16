#!/bin/bash

set -ex

export AWS_SSH_PRIVATE_KEY_PATH=$PWD/vagrant.pem
echo "$AWS_SSH_PRIVATE_KEY" > "$AWS_SSH_PRIVATE_KEY_PATH"

unzip lattice-bundle-ci/lattice-bundle-v*.zip

pushd lattice-bundle-v*/vagrant >/dev/null
  AWS_INSTANCE_NAME=ci-vagrant-aws vagrant up --provider=aws
  export $(vagrant ssh -c "grep '^DOMAIN=' /var/lattice/setup" 2>/dev/null | tr -d '\r')
popd >/dev/null

echo $DOMAIN > domain
