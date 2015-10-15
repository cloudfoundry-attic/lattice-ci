#!/bin/bash

set -ex

vagrant_dir=$PWD/deploy-vagrant-aws/lattice-bundle-v*/vagrant/

export AWS_SSH_PRIVATE_KEY_PATH=$PWD/deploy-vagrant-aws/vagrant.pem
cat <<< "$AWS_SSH_PRIVATE_KEY" > "$AWS_SSH_PRIVATE_KEY_PATH"

( cd $vagrant_dir && vagrant destroy -f )
