#!/bin/bash

ltc_version=$(git -C lattice-release/src/github.com/cloudfoundry-incubator/lattice/ltc describe --tags --always)
export GOPATH=$(cd lattice-release && pwd)

pushd lattice-release
  go install github.com/cloudfoundry-incubator/lattice/ltc
  tar czf "ltc-v${ltc_version}.tgz" -C bin/ ./ltc
popd
