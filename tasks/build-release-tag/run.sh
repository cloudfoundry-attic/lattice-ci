#!/bin/bash

set -ex

echo "v$(cat release-version/number)" > release-tag
