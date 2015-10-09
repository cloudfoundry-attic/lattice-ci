#!/bin/bash

pushd ./lattice-release/vagrant
  ./build --only=$BUILDER
popd
