#!/bin/bash

set -x -e

DIR=$PWD

cat <<< "$GITHUB_PRIVATE_KEY" > $DIR/github.key
chmod 600 $DIR/github.key
export GIT_SSH_COMMAND="/usr/bin/ssh -i $DIR/github.key"

cd lattice-website

gem install bundle

bundle install
apt-get install node -y --no-install-recommends

bundle exec middleman build
bundle exec middleman deploy
