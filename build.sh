#!/bin/bash
set -o pipefail

# Settings
org="ollijanatuinen"
repo="nomad-simplified"
nomad_version="1.10.3"
coredns_nomad_version="0.1.1"

# Build Docker images for Linux
DATE=`date +'%Y%m%d'`
i=1
TAG="$org/$repo:$DATE-$i"
# docker build . -t $TAG \
#   --build-arg NOMAD_VERSION=$nomad_version \
#   --build-arg COREDNS_NOMAD_VERSION=$coredns_nomad_version
# docker push $TAG

# Build ZIP files for Windows
mkdir -p dist/tmp
curl -sf https://releases.hashicorp.com/nomad/${nomad_version}/nomad_${nomad_version}_windows_amd64.zip -o dist/nomad.zip
unzip -o dist/nomad.zip -d dist/tmp/bin/
rm dist/nomad.zip

# Include configs
mkdir -p dist/tmp/etc/nomad.d dist/tmp/opt/nomad/data dist/tmp/opt/tls
cp -r nomad.d/* dist/tmp/etc/nomad.d/

# Remove Linux specific files
rm -f dist/tmp/etc/nomad.d/windows.hcl

# Create ZIP
cd dist/tmp
zip -r ../nomad-windows.zip .
cd ../..
rm -rf dist/tmp
