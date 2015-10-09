#!/bin/bash

set -ex

vagrant_dir=$PWD/vagrant
mkdir -p $vagrant_dir

export aws_ssh_private_key_path=$PWD/vagrant.pem
export aws_instance_name=concourse-vagrant

cat <<< "$AWS_SSH_PRIVATE_KEY" > "$aws_ssh_private_key_path"

curl -LO https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.4_x86_64.deb
dpkg -i vagrant_1.7.4_x86_64.deb

while ! vagrant plugin install vagrant-aws; do
  sleep 5
done

tar xzf vagrant-boxes/vagrant-boxes-v*.tgz lattice-aws.box
vagrant box add lattice/collocated lattice-aws.box

cp lattice-tgz/lattice-*.tgz $vagrant_dir/lattice.tgz
cp lattice-release/vagrant/Vagrantfile $vagrant_dir/Vagrantfile
pushd $vagrant_dir
  vagrant up --provider=aws
  export $(vagrant ssh -c "grep SYSTEM_DOMAIN /var/lattice/setup/lattice-environment" | egrep -o '(SYSTEM_DOMAIN=.+\.io)')
popd

sleep 120

echo $SYSTEM_DOMAIN > system_domain
