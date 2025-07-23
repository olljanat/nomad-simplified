$org="ollijanatuinen"
$repo="hashistack-simplified"
$winVersions = @(
  "ltsc2025",
  "ltsc2022",
  "ltsc2019"
)

# Make sure that we can build images which are compatible with old Windows versions
$env:DOCKER_BUILDKIT="0"
if (docker info -f '{{ .DriverStatus }}' | ForEach-Object {$_ -like "*containerd.snapshotter*"}) {
  throw "containerd snapshotter is not supported with this script"
}

$date=Get-Date -Format "yyyyMMdd"
$i=4
$manifestTag="$org/$repo" + ":" + "$date-$i-win"
$versionTags=""
forEach($v in $winVersions) {
  $tag = "$org/$repo" + ":" + "$date-win-$i-$v"
  docker build . -t $tag  `
    -f Dockerfile.windows `
    --build-arg TARGET_OS_VERSION=$v `
    --build-arg CONSUL_VERSION=1.21.2 `
    --build-arg NOMAD_VERSION=1.10.3 `
    --build-arg COREDNS_VERSION=1.12.2
  docker push $tag
  $versionTags += " $tag"
}

# $manifestCmd="docker buildx imagetools create --tag $manifestTag $versionTags"
$manifestCmd="docker manifest create $manifestTag $versionTags"
Invoke-Expression -Command $manifestCmd
docker manifest push $manifestTag
