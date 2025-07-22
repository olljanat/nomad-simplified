# Nomad simplified
Simplified Nomad setup for Linux + Windows.

Design pricipals:
* Keep it simple.
* Unify between Linux and Windows as much as possible
* [Manual clustering](https://developer.hashicorp.com/nomad/docs/deploy/clusters/connect-nodes#manual-clustering)

Images are published in Docker Hub repo [ollijanatuinen/hashistack-simplified](https://hub.docker.com/r/ollijanatuinen/hashistack-simplified)

# Preparation
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

# Deployment
## Servers (Linux)
```bash
export VERSION="20250723-linux-3"
export CONSUL_ENCRYPT="<replace>"
export SERVER1="192.168.8.119"
export SERVER2="192.168.8.120"
export SERVER3="192.168.8.121"
export NODE_IP="192.168.8.119"
export REGION="europe"
export DATACENTER="europe-1"
export NOMAD_NODE_NUM="1"
export COREDNS_NOMAD_TOKEN=""

docker compose -p nomad up -d
```
Then servers 2 and 3 to first one with command `nomad server join 192.168.8.119`

And then bootstrap ACLs with command `nomad acl bootstrap`

Look:
* https://developer.hashicorp.com/nomad/docs/secure/acl/bootstrap
* https://developer.hashicorp.com/nomad/docs/secure/acl/policies/create-policy


Create policy and token for CoreDNS
```hcl
namespace "*" {
  policy = "read"
}
```

```bash
nomad acl policy apply -description "CoreDNS integration" integration-coredns read-all.hcl
nomad acl token create -name="CoreDNS integration" -policy=integration-coredns -type=client
```

And re-deploy with `COREDNS_NOMAD_TOKEN` configured.

## SSO
Configure SSO with EntraID with:
```json
{
    "OIDCDiscoveryURL": "https://login.microsoftonline.com/00000000-0000-0000-0000-000000000000/v2.0",
    "OIDCClientID": "00000000-0000-0000-0000-000000000000",
    "OIDCClientSecret": "<secret>",
    "VerboseOIDCLogging": true,
    "OIDCScopes": [""],
    "AllowedRedirectURIs": [
      "https://nomad.example.com:4646/oidc/callback",
      "https://nomad.example.com:4646/ui/settings/tokens"
   ]
}
```
```bash
nomad acl auth-method create -type=oidc -name=EntraID -max-token-ttl=5m -token-locality=local -config=@oidc.json
```

Look:
* https://support.hashicorp.com/hc/en-us/articles/23181468381843-Configuring-Azure-Active-Directory-AAD-with-Nomad-using-OpenID-Connect-OIDC
* https://support.hashicorp.com/hc/en-us/articles/26540256080659-OIDC-Auth-setup-for-Nomad-using-Okta-as-idP


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

# docker compose -f docker-compose.windows.yml -p hashistack up -d
```

# Networking
In this setup we are using network configuration *without* any overlay technologies but instead of give each container network routable IP.

**TODO** Add explation why...

## Linux
```bash
docker network create \
  -d ipvlan \
  --subnet 10.0.0.0/16 \
  --gateway 10.0.0.1 \
  --opt parent=eth0 \
  --opt ipvlan_mode=l3 \
  containers
```

Sources:
* https://docs.docker.com/engine/network/drivers/ipvlan/
* https://blog.cloudtrooper.net/2023/05/10/ipvlan-with-docker-in-azure/


## Windows
For security reason, Nomad changed Hyper-V isolation to be default in Windows: https://github.com/hashicorp/nomad/pull/23452

So to get proper performance out for it, we are running Windows directly in hardware and using different Docker networks with direct VLAN mapping to isolate those from each others: https://github.com/hashicorp/nomad/pull/26363


**NOTE!!!** Use `transparent` driver in on-prem and `l2bridge` in Azure.

```powershell
docker network create `
  --driver <driver> `
  --subnet 10.0.0.0/16 `
  --gateway 10.0.0.1 `
  --opt com.docker.network.windowsshim.vlanid=4001 `
  dev

docker network create `
  --driver <driver> `
  --subnet 10.1.0.0/16 `
  --gateway 10.1.0.1 `
  --opt com.docker.network.windowsshim.vlanid=4002 `
  qa
docker network create `
  --driver <driver> `
  --subnet 10.2.0.0/16 `
  --gateway 10.2.0.1 `
  --opt com.docker.network.windowsshim.vlanid=4003 `
  prod
```

Sources:
* https://learn.microsoft.com/en-us/virtualization/windowscontainers/container-networking/advanced
* https://techcommunity.microsoft.com/blog/networkingblog/l2bridge-container-networking/1180923
