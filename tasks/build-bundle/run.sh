#!/bin/bash

set -ex

lattice_release_version=$(git -C lattice-release describe)
vagrant_box_version=$(cat vagrant-box-version/number)
lattice_tgz_url=$(cat lattice-tgz/url)

output_dir=lattice-bundle-$lattice_release_version
mkdir -p $output_dir/{vagrant,terraform}

box_version_filter="s/config\.vm\.box_version = \"0\"/config.vm.box_version = \"$vagrant_box_version\"/"
echo "LATTICE_TGZ_URL = \"$lattice_tgz_url\"" > $output_dir/vagrant/Vagrantfile
sed "$box_version_filter" lattice-release/vagrant/Vagrantfile >> $output_dir/vagrant/Vagrantfile

cp -r lattice-release/terraform/aws $output_dir/terraform/
filter='{"variable": (.variable + {"lattice_tgz_url": {"default": "'"$lattice_tgz_url"'"}})}'
jq "$filter" terraform-ami-metadata/ami-metadata-v* > $output_dir/terraform/aws/lattice.tf.json

zip -r ${output_dir}.zip "$output_dir"

