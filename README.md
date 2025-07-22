# Nomad simplified
Simplified Nomad setup for Linux + Windows.

Design pricipals:
* Keep it simple.
* Unify between Linux and Windows as much as possible

Images are published in Docker Hub repo [ollijanatuinen/hashistack-simplified](https://hub.docker.com/r/ollijanatuinen/hashistack-simplified)

## TLS
As first step, you should generate [TLS certificates](https://developer.hashicorp.com/nomad/docs/secure/traffic/tls)
```bash
export VERSION="20250723-linux-2"
export REGION="europe"

# Create certificate authority which is valid 20 years
docker run -it --rm -v ./tls:/tls -w /tls \
  ollijanatuinen/hashistack-simplified:${VERSION} \
  nomad tls ca create -days=7300

# Create certificate for Nomad servers which is valid 1 year
#
# NOTE:
# - region must match to region defined in docker-compose
# - IP addresses must match to Nomad servers IPs
docker run -it --rm -v ./tls:/tls -w /tls \
  ollijanatuinen/hashistack-simplified:${VERSION} \
  nomad tls cert create -server -days 365 \
  -region $REGION \
  -additional-ipaddress 192.168.8.119 \
  -additional-ipaddress 192.168.8.120 \
  -additional-ipaddress 192.168.8.121

# Create certificate for Nomad clients which is valid 5 years
docker run -it --rm -v ./tls:/tls -w /tls \
  ollijanatuinen/hashistack-simplified:${VERSION} \
  nomad tls cert create -client -days 1825 \
  -region $REGION

# Create certificate for Nomad CLI which is valid 30 days
docker run -it --rm -v ./tls:/tls -w /tls \
  ollijanatuinen/hashistack-simplified:${VERSION} \
  nomad tls cert create -cli -days 30 \
  -region $REGION

# Rename files
for file in "tls/$REGION-"*; do
  base=$(basename "$file")
  newname="${base/#$REGION/nomad}"
  newname="${newname/-nomad.pem/.pem}"
  newname="${newname/-key.pem/-key.pem}"
  mv "$file" "tls/$newname"
  echo "Renamed: $base -> $newname"
done

# Verify certificates content
openssl x509 -noout -text -in tls/<file>.pem
```

Then:
* distribute server and cli certs to servers
* distribute client cert to clients
* distribute certificate authority **public** key to all servers and clients
* store certificate authority **private** key to **offline** location and remove it from computer where it was generated

## Linux
```bash
export VERSION="20250723-linux-3"
export CONSUL_ENCRYPT="<replace>"
export SERVER1="192.168.8.119"
export SERVER2="192.168.8.120"
export SERVER3="192.168.8.121"
export NODE_IP="192.168.8.119"
export REGION="europe"
export DATACENTER="europe-1"

docker compose -f docker-compose.linux.yml -p hashistack up -d
```

## Windows
```powershell
$env:VERSION="20250723-3-win"
$env:CONSUL_ENCRYPT="<replace>"
$env:SERVER1="192.168.8.119"
$env:SERVER2="192.168.8.120"
$env:SERVER3="192.168.8.121"
$env:NODE_IP="192.168.8.201"
$env:REGION="europe"
$env:DATACENTER="europe-1"
$env:NODE_POOL="windows"
$env:HOSTNAME=$env:COMPUTERNAME.ToLower()

docker compose -f docker-compose.windows.yml -p hashistack up -d
```
