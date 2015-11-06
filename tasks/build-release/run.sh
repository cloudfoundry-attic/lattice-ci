#!/bin/bash

set -ex

echo -n "$(git -C lattice-release describe --abbrev=0)" > release-tag

