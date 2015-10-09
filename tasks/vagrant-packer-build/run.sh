#!/bin/bash
lattice_release_version=$(git describe -C ./lattice-release --tags --always)

pushd ./lattice-release/vagrant
  ./build
  tar czf "vagrant-boxes-${lattice_release_version}.tgz" lattice-*.box
popd
