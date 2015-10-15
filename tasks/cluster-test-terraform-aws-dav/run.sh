#!/bin/bash

set -ex

dot_lattice_dir=$HOME/.lattice
terraform_tmp_dir=$PWD/deploy-terraform-aws/lattice-bundle-v*/terraform/

mkdir $dot_lattice_dir

pushd $terraform_tmp_dir
    lattice_target=$(terraform output lattice_target)
    lattice_username=$(terraform output lattice_username)
    lattice_password=$(terraform output lattice_password)
    cat > $dot_lattice_dir/config.json <<EOF
{
    "target": "${lattice_target}",
    "username": "${lattice_username}",
    "password": "${lattice_password}",
    "active_blob_store": 0,
    "dav_blob_store": {
        "host": "${lattice_target}",
        "port": "8444",
        "username": "${lattice_username}",
        "password": "${lattice_password}"
    }
}
EOF
popd

curl -O http://receptor.${lattice_target}/v1/sync/linux/ltc
chmod a+x ltc

./ltc test -v --timeout=5m
