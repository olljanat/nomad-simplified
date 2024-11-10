#!/bin/bash


if [ ! -f "certs/nomad-simplified.crt" ]; then
  openssl req -x509 -newkey rsa:4096 -sha256 -days 1 \
    -nodes -keyout certs/all-in-one.key -out certs/all-in-one.crt -subj "/CN=nomad-simplified.local" \
    -addext "subjectAltName=DNS:nomad-simplified.local,DNS:node1.nomad-simplified.local,DNS:node2.nomad-simplified.local,DNS:node3.nomad-simplified.local,IP:127.0.0.1"
fi

if [ ! -f "certs/rootca.crt" ]; then
  openssl genrsa -out certs/rootca.key 4096
  openssl req -new -x509 -days 10950 -key certs/rootca.key -out certs/rootca.crt -config certs/rootca.cnf
fi

if [ ! -f "certs/node.crt" ]; then
  openssl genrsa -out certs/node.key 4096
  openssl req -new -key certs/node.key -out certs/node.csr -config certs/node.cnf 
  openssl ca -in certs/node.csr -out certs/node.crt -days 90 -notext -batch -config certs/openssl.cnf
fi

if [ ! -d "vault/data" ]; then
  openssl req -x509 -newkey rsa:4096 -sha256 -days 1 \
    -nodes -keyout vault/init-config/vault-init.key -out vault/init-config/vault-init.crt -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

  docker exec -it node1 docker compose -f vault-init.yml up -d
  sleep 30s

  docker exec -it node1 docker exec -it vault-init vault operator init -recovery-shares=1 -recovery-threshold=1 -format json > /tmp/init-result.json
  cat /tmp/init-result.json | jq '.recovery_keys_hex[]' | sed -e 's/"//g' > vault/secrets/recovery_key_0
  cat /tmp/init-result.json | jq '.root_token' | sed -e 's/"//g' > vault/secrets/vault_token

  docker exec -it node1 docker exec -it vault-init /etc/vault.d/vault-init.sh

  docker exec -it node1 docker compose -f vault-init.yml down
fi
