#!/bin/bash

set -ex

release_version=$(git -C lattice-release describe --abbrev=0)
bundle_sha=$(git rev-parse --short "$release_version^{commit}")

echo -n "$release_version" > release-tag

aws s3 cp "s3://$S3_BUCKET_NAME/acceptance" . --recursive --exclude "*" --include "*-g${bundle_sha}.zip"

unzip lattice-bundle-v*.zip
rm lattice-bundle-v*.zip
mv lattice-bundle-v* lattice-bundle-${release_version}
zip -r lattice-bundle-${release_version}.zip lattice-bundle-${release_version}
