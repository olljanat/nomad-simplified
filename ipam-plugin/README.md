# About
IPAM plugin for Docker with Nomad integration which allow you to allocate sub-ranges for Nomad namespaces like `--ip-range` option works in [docker network create](https://docs.docker.com/reference/cli/docker/network/create/) command.

> [!WARNING]  
> This requires Docker version containing: https://github.com/moby/moby/pull/50586

> [!CAUTION]
> This plugin will allocate sub-range completely which why it is recommended to skip first and last ranges from configured subnet.
> In example below you should **not** use sub-ranges which includes IPs `10.0.0.0` or `10.0.255.255`

# Usage
## Create network to Docker nodes
### Linux
> [!TIP]
> Use mode `l2` in on-prem and `l3` in Azure. Look [this](https://blog.cloudtrooper.net/2023/05/10/ipvlan-with-docker-in-azure) for more information.

```bash
docker network create \
  --driver ipvlan \
  --ipam-driver nomad-ipam \
  --subnet 10.0.0.0/16 \
  --gateway 10.0.0.1 \
  --opt parent=eth0 \
  --opt ipvlan_mode=l2 \
  containers
```
### Windows
> [!TIP]
> Use driver `transparent` in on-prem and `l2bridge` in Azure.

```powershell
docker network create `
  --driver transparent `
  --ipam-driver nomad-ipam `
  --subnet 10.0.0.0/16 `
  --gateway 10.0.0.1 `
  containers
```

## Create Nomad namespaces
```hcl
name = "example"
meta {
  ip_range = "10.0.1.0/24"
}
name = "foobar"
meta {
  ip_range = "10.0.2.0/24"
}
```

## Deploy test container
```hcl
job "test" {
  namespace = "example"
  group "web" {
    task "test.web" {
      driver = "docker"
      config {
        image = "ollijanatuinen/debug:nginx"
        network_mode = "containers"
      }
    }
  }
}
```
