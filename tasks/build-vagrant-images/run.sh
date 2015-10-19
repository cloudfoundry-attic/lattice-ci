#!/bin/bash

set -e

mkdir -p $HOME/.ssh
ssh-keyscan github.com >> $HOME/.ssh/known_hosts

eval $(ssh-agent)
echo "$GITHUB_SSH_KEY" > github_private_key.pem
chmod 0600 github_private_key.pem
ssh-add github_private_key.pem > /dev/null
rm github_private_key.pem

echo "$AWS_SSH_PRIVATE_KEY" > aws_private_key.pem

current_version=$(cat current-vagrant-box-version/number)
next_version=$(cat next-vagrant-box-version/number)
current_box_commit=$(cat "vagrant-box-commit/box-commit-v$current_version")
next_box_commit=$(git -C vagrant-image-changes rev-parse -q --verify HEAD)

if [[ $current_box_commit == $next_box_commit ]]; then
  echo -n $current_box_commit > "box-commit-v$current_version"
  echo -n $current_version > box-version-number
  exit 0
fi

git -C vagrant-image-changes submodule update --init --recursive

lattice_json=$(cat vagrant-image-changes/vagrant/lattice.json)
post_processor_json=$(cat <<EOF
{
  "post-processors": [[
    {
      "type": "vagrant"
    },
    {
      "type": "atlas",
      "only": ["amazon-ebs"],
      "token": "$ATLAS_TOKEN",
      "artifact": "lattice/collocated",
      "artifact_type": "vagrant.box",
      "metadata": {
        "provider": "aws",
        "version": "$next_version"
      }
    },
    {
      "type": "atlas",
      "only": ["vmware-iso"],
      "token": "$ATLAS_TOKEN",
      "artifact": "lattice/collocated",
      "artifact_type": "vagrant.box",
      "metadata": {
        "provider": "vmware_desktop",
        "version": "$next_version"
      }
    },
    {
      "type": "atlas",
      "only": ["virtualbox-iso"],
      "token": "$ATLAS_TOKEN",
      "artifact": "lattice/collocated",
      "artifact_type": "vagrant.box",
      "metadata": {
        "provider": "virtualbox",
        "version": "$next_version"
      }
    }
  ]]
}
EOF)

echo $lattice_json | jq '. + '"$post_processor_json" > vagrant-image-changes/vagrant/lattice.json

set -x

remote_tmp="/tmp/build-vagrant-images-$(date "+%Y-%m-%d-%H%M%Su")"
ssh -i aws_private_key.pem pivotal@54.85.98.162 -p 22222 mkdir -p $remote_tmp
rsync -e "ssh -p 22222 -i aws_private_key.pem" . pivotal@54.85.98.162:$remote_tmp
ssh -i aws_private_key.pem pivotal@54.85.98.162 -p 22222 \
  cd $remote_tmp; \
  vagrant-image-changes/vagrant/build -var "version=$next_version" -only="virtualbox-iso,vmware-iso"

vagrant-image-changes/vagrant/build -var "version=$next_version" -only="amazon-ebs"

echo -n $next_box_commit > "box-commit-v$next_version"
echo -n $next_version > box-version-number
