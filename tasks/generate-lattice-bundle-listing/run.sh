#!/bin/bash

set -ex

pushd lattice-ci/tasks/generate-lattice-bundle-listing
  bundle install
  bundle exec ./generate-listing.rb
popd
