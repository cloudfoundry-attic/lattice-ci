#!/bin/bash

set -e

mkdir -p $HOME/.ssh
ssh-keyscan github.com >> $HOME/.ssh/known_hosts

echo "$GITHUB_SSH_KEY" > github_private_key.pem
chmod 0600 github_private_key.pem
eval $(ssh-agent)
ssh-add github_private_key.pem > /dev/null
rm github_private_key.pem

ssh-keyscan github.com >> $HOME/.ssh/known_hosts

set -x

current_commit=$(git -C lattice-release rev-parse -q --verify HEAD)
latest_release_commit=$(git -C version-changes rev-parse -q --verify HEAD)
latest_release_tag=$(git -C version-changes describe)
latest_release_brand=v$(cat version-changes/VERSION)
latest_release_version=$(cat github-release/tag)

if [[ $latest_release_tag == $latest_release_brand ]]; then
  [[ $latest_release_tag == $latest_release_version ]] && exit 0
  echo "Currently processing release ($latest_release_tag). Please try again "
  exit 1
fi

if [[ $current_commit != $latest_release_commit ]]; then
  echo "Release (VERSION-changing) commit fetched with future changes."
  echo "Please push a new release commit without other changes."
  exit 1
fi

git config --global user.name "Concourse CI"
git config --global user.email "pivotal-lattice-eng@pivotal.io"
git -C lattice-release tag -f -a "$latest_release_brand" -m "$latest_release_brand"
git -C lattice-release push -f origin "refs/tags/$latest_release_brand:refs/tags/$latest_release_brand"
