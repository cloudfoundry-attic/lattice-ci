#!/bin/bash

set -ex

version=$([[ -f $VERSION_FILE ]] && cat $VERSION_FILE)
lattice_release_version=${version:-$(git -C lattice-release describe --tags --always)}
lattice_tgz_url="$LATTICE_URL_BASE/lattice-$lattice_release_version.tgz"

output_dir=lattice-vagrant-$lattice_release_version
mkdir -p $output_dir

( echo "LATTICE_TGZ_URL = '$lattice_tgz_url'"; cat lattice-release/vagrant/Vagrantfile ) > $output_dir/Vagrantfile

zip -r $output_dir.zip $output_dir


