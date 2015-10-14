#!/bin/bash

set -ex

lattice-release/terraform/build -color -var "version=$(cat $VERSION_FILE)" -only=$NAMES | tee build.log
 # parse this?
