#!/bin/bash

set -ex

lattice_version=$(git -C lattice-release describe --tags --always)
./lattice-release/release/build "lattice-${lattice_version}.tgz"
