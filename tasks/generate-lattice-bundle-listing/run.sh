#!/bin/bash

set -ex

export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

pushd lattice-ci/tasks/generate-lattice-bundle-listing
  bundle install
  bundle exec ./generate-listing.rb
popd
