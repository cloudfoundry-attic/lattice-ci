#!/bin/bash

set -ex

current_version=$(cat current-vagrant-box-version/number)
next_version=$(cat next-vagrant-box-version/number)
current_box_commit=$(cat "vagrant-box-commit/box-commit-v$current_version")
next_box_commit=$(git -C vagrant-image-changes rev-parse -q --verify HEAD)

if [[ $current_box_commit == $next_box_commit ]]; then
  echo $current_version > box-version-number
  exit 0
fi

mkdir -p $HOME/.ssh
ssh-keyscan github.com >> $HOME/.ssh/known_hosts

set +x
eval $(ssh-agent)
echo "$GITHUB_SSH_KEY" > private_key.pem
chmod 0600 private_key.pem
ssh-add private_key.pem > /dev/null
rm private_key.pem
set -x

pushd vagrant-image-changes > /dev/null
  git submodule update --init --recursive
popd > /dev/null

lattice_json=$(cat vagrant-image-changes/vagrant/lattice.json)
post_processor_json=$(cat <<EOF
{
  "post-processors": [[
    {"type": "vagrant"},
    {
      "type": "atlas",
      "token": "$ATLAS_TOKEN",
      "artifact": "lattice/collocated",
      "artifact_type": "vagrant.box",
      "metadata": {
        "provider": "{{.Provider}}",
        "version": "$next_version"
      }
    }
  ]]
}
EOF)

echo $lattice_json | jq '. + '"$post_processor_json" > vagrant-image-changes/vagrant/lattice.json

vagrant-image-changes/vagrant/build -var "version=$next_version" -only=$NAMES
echo $next_box_commit > "box-commit-v$next_version"
echo $next_version > box-version-number
