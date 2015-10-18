#!/bin/bash

set -ex

dot_lattice_dir=$HOME/.lattice
terraform_dir=$PWD/deploy-terraform-aws/lattice-bundle-v*/terraform/aws

mkdir -p $dot_lattice_dir

pushd $terraform_dir >/dev/null
    target=$(terraform output target)
    username=$(terraform output username)
    password=$(terraform output password)
    cat > $dot_lattice_dir/config.json <<EOF
{
    "target": "${target}",
    "username": "${username}",
    "password": "${password}",
    "active_blob_store": 1,
    "s3_blob_store": {
        "region": "${AWS_REGION}",
        "access_key": "${AWS_ACCESS_KEY_ID}",
        "secret_key": "${AWS_SECRET_ACCESS_KEY}",
        "bucket_name": "${S3_BUCKET_NAME}"
    }
}
EOF
popd >/dev/null

curl -O "http://receptor.${target}/v1/sync/linux/ltc"
chmod +x ltc

./ltc test -v --timeout=5m
