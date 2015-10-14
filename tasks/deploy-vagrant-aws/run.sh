#!/bin/bash

set -ex

vagrant_dir=$PWD/vagrant
mkdir -p $vagrant_dir

aws_ssh_private_key_path=$PWD/vagrant.pem
aws_instance_name=ci-vagrant-aws

echo "$AWS_SSH_PRIVATE_KEY" > "$aws_ssh_private_key_path"


cp lattice-tgz/lattice-*.tgz $vagrant_dir/lattice.tgz
cp lattice-release/vagrant/Vagrantfile $vagrant_dir/Vagrantfile

pushd $vagrant_dir >/dev/null
  vagrant up --provider=aws
  export $(vagrant ssh -c "grep '^DOMAIN=' /var/lattice/setup" 2>/dev/null)
popd >/dev/null

echo $DOMAIN > domain
