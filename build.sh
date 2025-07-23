#!/bin/bash

org="ollijanatuinen"
repo="hashistack-simplified"

DATE=`date +'%Y%m%d'`
i=4
TAG="$org/$repo:$DATE-linux-$i"
docker build . -t $TAG \
  -f Dockerfile.linux \
  --build-arg CONSUL_VERSION=1.21.2 \
  --build-arg NOMAD_VERSION=1.10.3 \
  --build-arg COREDNS_VERSION=1.12.2
docker push $TAG
