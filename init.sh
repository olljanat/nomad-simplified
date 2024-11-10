#!/bin/bash

if [ ! -f "certs/nomad-simplified.crt" ]; then
  openssl req -x509 -newkey rsa:4096 -sha256 -days 90 \
    -nodes -keyout certs/all-in-one.key -out certs/all-in-one.crt -subj "/CN=nomad-simplified.local" \
    -addext "subjectAltName=DNS:nomad-simplified.local,DNS:node1.nomad-simplified.local,DNS:node2.nomad-simplified.local,DNS:node3.nomad-simplified.local,IP:127.0.0.1"
fi

if [ ! -d "vault/data" ]; then
  docker exec -it node1 docker compose -f vault-init.yml up -d
  sleep 30s

  docker exec -it node1 docker exec -it vault-init vault operator init -recovery-shares=1 -recovery-threshold=1 -format json > /tmp/init-result.json
  cat /tmp/init-result.json | jq '.recovery_keys_hex[]' | sed -e 's/"//g' > vault/secrets/recovery_key_0
  cat /tmp/init-result.json | jq '.root_token' | sed -e 's/"//g' > vault/secrets/vault_token

  docker exec -it node1 docker exec -it vault-init /etc/vault.d/vault-init.sh

  docker exec -it node1 docker compose -f vault-init.yml down
fi
