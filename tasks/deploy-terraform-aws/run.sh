#!/bin/bash

set -ex

unzip lattice-bundle-ci/lattice-bundle-v*.zip
terraform_dir=$PWD/lattice-bundle-v*/terraform

cat <<< "$AWS_SSH_PRIVATE_KEY" > $terraform_dir/key.pem

cat > $terraform_dir/lattice.tfvars <<EOF
username = "user"
password = "pass"

aws_access_key_id = "$AWS_ACCESS_KEY_ID"
aws_secret_access_key = "$AWS_SECRET_ACCESS_KEY"
aws_ssh_private_key_name = "concourse-test"
aws_ssh_private_key_path = "${terraform_dir}/key.pem"

aws_region = "us-east-1"
cell_count = "3"
EOF

pushd $terraform_dir
    terraform apply || terraform apply
popd

sleep 60
