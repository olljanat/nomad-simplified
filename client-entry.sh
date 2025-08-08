#!/bin/bash

# Configure advertise and bind addresses so we don't need publish HTTP port from clients
export CLUSTER_CONFIG='advertise {\n  http = "'$NODE_IP'"\n}\n'
export CLUSTER_CONFIG=$CLUSTER_CONFIG'bind_addr = "'$NODE_IP'"\n'

# Generate cluster join config for Nomad clients
export CLUSTER_CONFIG=$CLUSTER_CONFIG'client {\n  servers = ["'
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
export CLUSTER_CONFIG=$CLUSTER_CONFIG'"]\n}'
export NOMAD_CLUSTER="$NOMAD_CLUSTER    $CLUSTER_CONFIG"
echo -e "$CLUSTER_CONFIG" | tee /etc/nomad.d/cluster.hcl

$@ &
child_pid=$!

cleanup() {
  echo "Caught SIGINT. Forwarding to child process $child_pid..."
  kill -2 "$child_pid"
}

trap cleanup INT
wait "$child_pid"
exit $?
