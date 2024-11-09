#!/bin/bash

openssl req -x509 -newkey rsa:4096 -sha256 -days 1 \
  -nodes -keyout vault/init-config/vault-init.key -out vault/init-config/vault-init.crt -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,IP:127.0.0.1"

docker exec -it nomad1 docker compose -f vault-init.yml up -d
docker exec -it nomad1 docker exec -it vault-init vault operator init

docker exec -it nomad1 docker compose -f vault-init.yml down
