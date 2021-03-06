#!/bin/bash

set -ex

pushd lattice-release >/dev/null
  source .envrc
  go install github.com/onsi/ginkgo/ginkgo
  go install github.com/coreos/etcd
  go install github.com/apcera/gnatsd

  curl -L -O "https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip"
  unzip 0.5.2_linux_amd64.zip -d bin
  chmod +x bin/consul

  ginkgo -r --randomizeAllSpecs --randomizeSuites --failOnPending --trace src/github.com/cloudfoundry-incubator/receptor
popd >/dev/null
