#!/bin/bash

set -ex

current_commit=$(git -C lattice-release rev-parse -q --verify HEAD)
latest_release_commit=$(git -C version-changes rev-parse -q --verify HEAD)
latest_release_tag=$(git -C version-changes describe)
latest_release_brand=$(cat version-changes/VERSION)

[[ latest_release_tag == latest_release_brand ]] && exit 0

if [[ $current_commit != $latest_release_commit ]]; then
  echo "ERROR: release (version-bump) commit fetched with future changes. Aborting..."
  exit 1
fi

git -C lattice-release tag -am '' $latest_release_brand
git -C lattice-release push -f origin "refs/tags/$latest_release_brand:refs/tags/$latest_release_brand"
