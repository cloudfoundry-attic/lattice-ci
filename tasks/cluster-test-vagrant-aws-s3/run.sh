#!/bin/bash

set -ex

DOMAIN=`cat deploy-vagrant-aws/domain`

mkdir ~/.lattice

cat > ~/.lattice/config.json <<EOF
{
  "target": "${DOMAIN}",
  "active_blob_store": 1,
  "s3_blob_store": {
    "region": "${AWS_REGION}",
    "access_key": "${AWS_ACCESS_KEY_ID}",
    "secret_key": "${AWS_SECRET_ACCESS_KEY}",
    "bucket_name": "${S3_BUCKET_NAME}"
  }
}
EOF

curl -O http://receptor.${DOMAIN}/v1/sync/linux/ltc
chmod a+x ltc
./ltc test -v -t 5m || ./ltc test -v -t 10m
