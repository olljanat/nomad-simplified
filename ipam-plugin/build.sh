#!/bin/bash

USAGE="Usage: ./build.sh <Docker Hub Organization> <version>"

if [ "$1" == "--help" ] || [ "$#" -lt "2" ]; then
	echo $USAGE
	exit 0
fi

ORG=$1
VERSION=$2
LDFLAGS_STRING=" -w -extldflags -static -X main.Version=$VERSION"

rm -rf rootfs
docker plugin disable $ORG/docker-ipam-nomad:v$VERSION
docker plugin rm $ORG/docker-ipam-nomad:v$VERSION

mkdir -p rootfs
mkdir -p rootfs/etc/ssl/certs/
cp /etc/ssl/certs/ca-certificates.crt rootfs/etc/ssl/certs/
CGO_ENABLED=0 go build -a -tags netgo -ldflags "${LDFLAGS_STRING}" -o docker-ipam-nomad
cp docker-ipam-nomad rootfs/

docker plugin create $ORG/docker-ipam-nomad:v$VERSION .
docker plugin push $ORG/docker-ipam-nomad:v$VERSION

docker plugin rm $ORG/docker-ipam-nomad:v$VERSION

GOOS=windows go build -ldflags "${LDFLAGS_STRING}" -o docker-ipam-nomad.exe
