#!/bin/bash
set -euxo pipefail

org=$1
repo=$2
nomad_version=$3
coredns_nomad_version=$4
version=$5

# Build Docker images for Linux
TAG="$org/$repo:$version"
docker build . -t $TAG \
  --build-arg NOMAD_VERSION=$nomad_version \
  --build-arg COREDNS_NOMAD_VERSION=$coredns_nomad_version
docker push $TAG

# Build ZIP files for Windows
mkdir -p dist/tmp
wget https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_windows_amd64.zip -O dist/nomad.zip
unzip -o dist/nomad.zip -d dist/tmp/bin/
rm dist/nomad.zip

# Include configs
mkdir -p dist/tmp/etc/nomad.d dist/tmp/opt/nomad/data dist/tmp/logs dist/tmp/opt/tls
cp -r nomad.d/* dist/tmp/etc/nomad.d/

# Remove Linux specific files
rm -f dist/tmp/etc/nomad.d/linux.hcl
rm -rf dist/tmp/etc/nomad.d/role

# Create ZIP
cd dist/tmp
zip -r ../nomad-windows.zip .
cd ../..
rm -rf dist/tmp
