#!/bin/bash

set -ex

pushd lattice-release >/dev/null
  source .envrc
  go install github.com/onsi/ginkgo/ginkgo
  ginkgo -r --randomizeAllSpecs --randomizeSuites --failOnPending --trace src/$PACKAGE
popd >/dev/null
