#!/bin/bash

org="ollijanatuinen"
repo="nomad-simplified"

DATE=`date +'%Y%m%d'`
i=5
TAG="$org/$repo:$DATE-linux-$i"
docker build . -t $TAG \
  -f Dockerfile.linux \
  --build-arg NOMAD_VERSION=1.10.3 \
  --build-arg COREDNS_NOMAD_VERSION=0.1.1
docker push $TAG
