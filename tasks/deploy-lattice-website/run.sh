#!/bin/bash

set -e

echo "$GITHUB_PRIVATE_KEY" > github.key
chmod 600 github.key
export GIT_SSH_COMMAND="/usr/bin/ssh -i $PWD/github.key"

set -x

git config --global user.email "pivotal-lattice-eng@pivotal.io"
git config --global user.name "Concourse CI"

pushd lattice-website >/dev/null
  bundle install
  apt-get install node -y --no-install-recommends

  bundle exec middleman build
  bundle exec middleman deploy
popd >/dev/null
