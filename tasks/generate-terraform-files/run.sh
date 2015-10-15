#!/bin/bash

set -ex

version=$([[ -f $VERSION_FILE ]] && cat $VERSION_FILE)
lattice_release_version=${version:-$(git -C lattice-release describe --tags --always)}
lattice_tgz_url="$LATTICE_URL_BASE/lattice-$lattice_release_version.tgz"

input_dir=lattice-release/terraform/$PROVIDER
output_dir=lattice-terraform-$PROVIDER-$lattice_release_version
mkdir -p $output_dir

sed 's%# lattice_tgz_url =.*$%lattice_tgz_url = "'$lattice_tgz_url'"%' \
  < $input_dir/terraform.tfvars.sample > $output_dir/terraform.tfvars
cp $input_dir/*.tf $output_dir/

zip -r $output_dir.tgz $output_dir
