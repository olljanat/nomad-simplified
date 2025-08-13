# About
IPAM plugin for Docker with Nomad integration which allow you to allocate sub-ranges for Nomad namespaces like `--ip-range` option works in [docker network create](https://docs.docker.com/reference/cli/docker/network/create/) command.

> [!WARNING]
> This requires Docker version containing: https://github.com/moby/moby/pull/50586

> [!CAUTION]
> This plugin will allocate sub-range completely which why it is recommended to skip first and last ranges from configured subnet.
> In example below you should **not** use sub-ranges which includes IPs `10.0.0.0` or `10.0.255.255`

> [!CAUTION]
> Current implementation expects that each network which uses this plugin registers service with `provider=nomad` and `address_mode=driver` options enabled. Without those you will see IP conflicts.

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
  ip_range_europe1 = "10.0.1.0/24"
}
name = "foobar"
meta {
  ip_range_europe1 = "10.0.2.0/24"
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

# Installation
## Linux
```bash
docker plugin install \
  --grant-all-permissions \
  ollijanatuinen/docker-ipam-nomad:v0.6 \
  NOMAD_ADDR="http://127.0.0.1:4646" \
  NOMAD_DATACENTER="europe1" \
  NOMAD_TOKEN="abc123" \
  NOMAD_SKIP_VERIFY="true"
```

> [!WARNING]
> It seems to be that because of Docker limitations, using of `--alias` parameter when installing IPAM plugins will result to error message `invalid ipam driver`

## Windows
```powershell
# Copy binary and create service
Copy-Item -Path docker-ipam-nomad.exe -Destination "C:\Program Files\docker"
New-Service -Name "docker-ipam-nomad" -DisplayName "Docker IPAM plugin with Nomad integration" `
  -BinaryPathName "C:\Program Files\docker\docker-ipam-nomad.exe" -StartupType Automatic

# Register eventlog handler
$log = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application\docker-ipam-nomad"
New-Item -Path $log -Force
Set-ItemProperty -Path $log -Name CustomSource -Value 1
Set-ItemProperty -Path $log -Name EventMessageFile -Value "%SystemRoot%\System32\EventCreate.exe"
Set-ItemProperty -Path $log -Name TypesSupported -Value 7

# Make Docker service depend on of plugin service
## Please note that you need reboot server before this is effective.
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\docker" `
  -Name DependOnService -Type MultiString -Value @("hns","vmcompute","docker-ipam-nomad")

# Add environment variable for service
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\docker-ipam-nomad" `
  -Name Environment `
  -Type MultiString `
  -Value @(
    "NOMAD_DATACENTER=europe1",
    "NOMAD_TOKEN=abc123"
)
```
