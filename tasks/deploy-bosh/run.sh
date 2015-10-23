#!/bin/bash

set +ex

# upload the cloudformation.json file to s3
aws cloudformation create-stack --stack-name ci-test --template-url http://lattice.s3.amazonaws.com/ci/cloudformation.json
