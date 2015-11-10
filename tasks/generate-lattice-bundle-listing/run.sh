#!/bin/bash

set -ex

pushd lattice-ci/tasks/generate-lattice-bundle-listing >/dev/null
  bundle install
  bundle exec ./generate-listing.rb
popd >/dev/null
