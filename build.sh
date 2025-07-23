#!/bin/bash

org="ollijanatuinen"
repo="nomad-simplified"

DATE=`date +'%Y%m%d'`
i=1
TAG="$org/$repo:$DATE-$i"
docker build . -t $TAG \
  --build-arg NOMAD_VERSION=1.10.3 \
  --build-arg COREDNS_NOMAD_VERSION=0.1.1
docker push $TAG
