#!/bin/bash

next_version=$(cat next-vagrant-box-version/number)

for p in $PROVIDERS; do
  errors=$(curl https://atlas.hashicorp.com/api/v1/box/lattice/collocated/version/$next_version/provider/$p?access_token='$ATLAS_TOKEN' | jq .errors -r)
  if [[ errors != 'null' ]]; then
    curl https://atlas.hashicorp.com/api/v1/box/lattice/collocated/version/$next_version \
      -X DELETE \
      -d access_token=$ATLAS_TOKEN
    exit 0
  fi
done

