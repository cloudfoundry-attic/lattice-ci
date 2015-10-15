#!/bin/bash

set -ex

dot_lattice_dir=$HOME/.lattice
terraform_dir=$PWD/deploy-terraform-aws/lattice-bundle-v*/terraform/

mkdir -p $dot_lattice_dir

pushd $terraform_dir
    lattice_target=$(terraform output lattice_target)
    lattice_username=$(terraform output lattice_username)
    lattice_password=$(terraform output lattice_password)
    cat > $dot_lattice_dir/config.json <<EOF
{
    "target": "${lattice_target}",
    "username": "${lattice_username}",
    "password": "${lattice_password}",
    "active_blob_store": 1,
    "s3_blob_store": {
        "region": "${AWS_REGION}",
        "access_key": "${AWS_ACCESS_KEY_ID}",
        "secret_key": "${AWS_SECRET_ACCESS_KEY}",
        "bucket_name": "${S3_BUCKET_NAME}"
    }
}
EOF
popd

curl -O http://receptor.${lattice_target}/v1/sync/linux/ltc
chmod a+x ltc

./ltc test -v --timeout=5m
