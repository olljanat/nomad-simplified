#!/bin/bash

if [ ! -f "secrets/nomad-simplified.crt" ]; then
  openssl req -x509 -newkey rsa:4096 -sha256 -days 90 \
    -nodes -keyout secrets/nomad-simplified.key -out secrets/nomad-simplified.crt -subj "/CN=dc.consul" \
    -addext "subjectAltName=DNS:dc.consul,DNS:*.dc.consul,DNS:node1,DNS:node2,DNS:node3,IP:127.0.0.1"
  cp secrets/nomad-simplified.crt secrets/rootca.crt
fi

if [ ! $(docker exec -it node1 docker volume ls --filter name=vault -q) ]; then
  docker exec -it node1 docker compose -f vault-init.yml up -d
  sleep 30s

  docker exec -it node1 docker exec -it vault-init vault operator init -recovery-shares=1 -recovery-threshold=1 -format json > /tmp/init-result.json
  cat /tmp/init-result.json | jq '.recovery_keys_hex[]' | sed -e 's/"//g' > secrets/recovery_key_0
  cat /tmp/init-result.json | jq '.root_token' | sed -e 's/"//g' > secrets/vault_token

  docker exec -it node1 docker exec -it vault-init /etc/vault.d/vault-init.sh

  docker exec -it node1 docker compose -f vault-init.yml down
fi
