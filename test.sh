#!/bin/bash

source .versions

# docker exec -it node1 docker compose -f vault-init.yml up -d
# docker exec -it node1 docker exec -it vault-init vault operator init


sudo ip address add 169.254.169.254/32 dev eth0
docker compose -f lab.yml up -d


# docker exec -it node1 docker compose up
