#!/bin/bash

set -ex

lattice_version=$(cat lattice-tgz-version/number)
./lattice-release/release/build "lattice-v${lattice_version}.tgz"
