#!/bin/bash

lattice_version=$(git -C lattice-release/src/github.com/cloudfoundry-incubator/lattice describe --tags --always)
pushd lattice-release
  ./release/build "lattice-v${lattice_version}.tgz"
popd
