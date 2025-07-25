# Test
## Start test Nomad
```bash
docker compose up -d
```

## Run plugin
```bash
go build

sudo -s
export NOMAD_DATACENTER="dc1"
./ipam-plugin
```

## Create test networks
```bash
docker network create \
  --driver bridge \
  --ipam-driver nomad-ipam \
  --subnet 100.64.1.0/24 \
  --gateway 100.64.1.1 \
  dc1

docker network create \
  --driver bridge \
  --ipam-driver nomad-ipam \
  --subnet 100.64.2.0/24 \
  --gateway 100.64.2.1 \
  dc2
```

## Create namespaces
```bash
nomad namespace apply ns_test1.hcl
nomad namespace apply ns_test2.hcl
```

## Create test jobs
```bash
nomad job run -namespace test1 job_dc1.hcl
nomad job run -namespace test1 job_dc2.hcl
```

# Cleanup
```bash
nomad job stop -namespace=test1 test2-dc1
nomad job stop -namespace=test1 test1-dc1
```
