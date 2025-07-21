#!/bin/bash

if [ ! -f "/opt/tls/agent.crt" ]; then
  echo "File /opt/tls/agent.crt does not exist. Generating self-signed"
  openssl req -x509 -newkey rsa:4096 -sha256 -days 1 \
    -nodes -keyout /opt/tls/agent.key -out /opt/tls/agent.crt -subj "/CN=${HOSTNAME}.node.${CONSUL_DATACENTER}.consul" \
    -addext "subjectAltName=DNS:localhost,DNS:consul.service.consul,DNS:consul.service.${CONSUL_DATACENTER}.consul,IP:${HOST_IP},IP:127.0.0.1"
  cp /opt/tls/agent.crt /opt/tls/ca.crt
fi

if [[ -n "$CONSUL_RETRY_JOIN" ]]; then
  CLUSTER_CONFIG='retry_join = ['
  CLUSTER_CONFIG+=$CONSUL_RETRY_JOIN
  CLUSTER_CONFIG+=']'
  echo -e "$CLUSTER_CONFIG" | sudo tee /etc/consul.d/cluster.hcl
fi

$@
