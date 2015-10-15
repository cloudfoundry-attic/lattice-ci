#!/bin/bash

set -ex

lattice_release_version=$(git -C lattice-release describe --tags --always)
vagrant_box_version=$(cat vagrant-box-version/number)
lattice_tgz_url=$(cat lattice-tgz/url)

output_dir=lattice-bundle-$lattice_release_version
mkdir -p $output_dir/vagrant $output_dir/terraform/aws

vagrantfile=$(sed "s/config\.vm\.box_version = '0'/config.vm.box_version = '$vagrant_box_version'/" lattice-release/vagrant/Vagrantfile)
echo "LATTICE_TGZ_URL = '$lattice_tgz_url'\n$vagrantfile" > $output_dir/vagrant/Vagrantfile

cp -r lattice-release/terraform/aws/ $output_dir/teraform/aws/
echo "{\"variables\": $(jq '.variables + {"lattice-tgz-url": {"default": "'$LATTICE_TGZ_URL'"}}' terraform-ami-metadata/ami-metadata-v*)}" \
  > $output_dir/terraform/aws/ami-metadata.tf.json

zip -r ${output_dir}.zip "$output_dir"

