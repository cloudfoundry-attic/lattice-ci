#!/bin/bash

set -e

mkdir -p $HOME/.ssh
ssh-keyscan github.com >> $HOME/.ssh/known_hosts

echo "$GITHUB_PRIVATE_KEY" > github_private_key.pem
chmod 0600 github_private_key.pem

export GIT_SSH_COMMAND="/usr/bin/ssh -i $PWD/github_private_key.pem"

set -x

git config --global user.email "pivotal-lattice-eng@pivotal.io"
git config --global user.name "Concourse CI"

pushd lattice-website >/dev/null
  bundle install
  apt-get install node -y --no-install-recommends

  bundle exec middleman build
  bundle exec middleman deploy
popd >/dev/null
