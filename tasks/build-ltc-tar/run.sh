#!/bin/bash

pushd lattice-release
  go install github.com/cloudfoundry-incubator/lattice/ltc
  tar czf ltc.tgz -C bin/ ./ltc
popd
