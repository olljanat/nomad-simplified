#!/bin/sh

# Generate cluster join config for Consul and Nomad
export CLUSTER_CONFIG='retry_join = ["'
export NOMAD_CLUSTER='client {\n  server_join {\n'
export FIRST_SERVER=true
if [[ -n "$SERVER1" ]]; then
  export CLUSTER_CONFIG=$CLUSTER_CONFIG$SERVER1
  export FIRST_SERVER=false
fi
if [[ -n "$SERVER2" ]]; then
  if [[ "$FIRST_SERVER" != "true" ]]; then
    export CLUSTER_CONFIG=$CLUSTER_CONFIG'","'
  fi
  export CLUSTER_CONFIG=$CLUSTER_CONFIG$SERVER2
  export FIRST_SERVER=false
fi
if [[ -n "$SERVER3" ]]; then
  if [[ "$FIRST_SERVER" != "true" ]]; then
    export CLUSTER_CONFIG=$CLUSTER_CONFIG'","'
  fi
  export CLUSTER_CONFIG=$CLUSTER_CONFIG$SERVER3
fi
export CLUSTER_CONFIG=$CLUSTER_CONFIG'"]'
export NOMAD_CLUSTER="$NOMAD_CLUSTER    $CLUSTER_CONFIG"
export NOMAD_CLUSTER=$NOMAD_CLUSTER'\n  }\n}'
echo -e "$CLUSTER_CONFIG" | tee /etc/consul.d/cluster.hcl
echo -e "$NOMAD_CLUSTER" | tee /etc/nomad.d/cluster.hcl

$@
