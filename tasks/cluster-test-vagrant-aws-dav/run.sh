#!/bin/bash

set -ex

lattice_target=$(cat deploy-vagrant-aws/domain)

curl -O "http://receptor.${lattice_target}/v1/sync/linux/ltc"
chmod +x ltc

./ltc target "$lattice_target"
./ltc test -v -t 5m || ./ltc test -v -t 10m
