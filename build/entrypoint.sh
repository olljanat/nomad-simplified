#!/bin/bash

# if [ ! -f "/opt/tls/agent.crt" ]; then
#   echo "File /opt/tls/agent.crt does not exist. Generating self-signed"
#   openssl req -x509 -newkey rsa:4096 -sha256 -days 1 \
#     -nodes -keyout /opt/tls/agent.key -out /opt/tls/agent.crt -subj "/CN=${HOSTNAME}.node.${CONSUL_DATACENTER}.consul" \
#     -addext "subjectAltName=DNS:localhost,DNS:consul.service.consul,DNS:consul.service.${CONSUL_DATACENTER}.consul,IP:${HOST_IP},IP:127.0.0.1"
#   cp /opt/tls/agent.crt /opt/tls/ca.crt
# fi

# Generate cluster join config for Consul and Nomad
CLUSTER_CONFIG='retry_join = ["'
NOMAD_CLUSTER='client {\n  server_join {\n    '
FIRST_SERVER=true
if [[ -n "$SERVER1" ]]; then
  CLUSTER_CONFIG+=$SERVER1
  FIRST_SERVER=false
fi
if [[ -n "$SERVER2" ]]; then
  if [[ "$FIRST_SERVER" != "true" ]]; then
    CLUSTER_CONFIG+='","'
  fi
  CLUSTER_CONFIG+=$SERVER2
  FIRST_SERVER=false
fi
if [[ -n "$SERVER3" ]]; then
  if [[ "$FIRST_SERVER" != "true" ]]; then
    CLUSTER_CONFIG+='","'
  fi
  CLUSTER_CONFIG+=$SERVER3
fi
CLUSTER_CONFIG+='"]'
NOMAD_CLUSTER+=$CLUSTER_CONFIG
NOMAD_CLUSTER+='\n  }\n}'
echo -e "$CLUSTER_CONFIG" | tee /etc/consul.d/cluster.hcl
echo -e "$NOMAD_CLUSTER" | tee /etc/nomad.d/cluster.hcl

$@
