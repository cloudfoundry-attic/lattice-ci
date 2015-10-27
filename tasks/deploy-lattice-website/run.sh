#!/bin/bash

set -e

echo "$GITHUB_SSH_KEY" > github_private_key.pem
chmod 0600 github_private_key.pem

export GIT_SSH_COMMAND="/usr/bin/ssh -i $PWD/github_private_key.pem"

set -x

pushd lattice-website >/dev/null
  bundle install
  apt-get install node -y --no-install-recommends

  bundle exec middleman build
  bundle exec middleman deploy
popd >/dev/null
