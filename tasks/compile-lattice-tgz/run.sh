#!/bin/bash

set -ex

lattice_tgz_version=$(cat lattice-tgz-version/number)
./lattice-release/release/build "lattice-v${lattice_tgz_version}.tgz" "$lattice_tgz_version"
