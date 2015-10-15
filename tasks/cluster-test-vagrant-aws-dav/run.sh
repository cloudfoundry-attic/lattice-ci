#!/bin/bash

set -ex

DOMAIN=`cat deploy-vagrant-aws/domain`

curl -O http://receptor.${DOMAIN}/v1/sync/linux/ltc
chmod a+x ltc

./ltc target "$DOMAIN"
./ltc test -v -t 5m || ./ltc test -v -t 10m
