#!/bin/bash

docker exec -it nomad1 docker compose -f vault-init.yml up -d
docker exec -it nomad1 docker exec -it vault-init vault operator init

docker exec -it nomad1 docker compose -f vault-init.yml down
