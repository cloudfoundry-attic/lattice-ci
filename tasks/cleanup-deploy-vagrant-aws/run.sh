#!/bin/bash

set -ex

vagrant_dir=$PWD/deploy-vagrant-aws/lattice-bundle-v*/vagrant/

export AWS_SSH_PRIVATE_KEY_PATH=$PWD/deploy-vagrant-aws/vagrant.pem
cat <<< "$AWS_SSH_PRIVATE_KEY" > "$AWS_SSH_PRIVATE_KEY_PATH"

curl -LO https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4_x86_64.deb
dpkg -i vagrant_1.7.4_x86_64.deb

while ! vagrant plugin install vagrant-aws; do
  sleep 5
done

( cd $vagrant_dir && vagrant destroy -f )
