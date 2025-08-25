#!/bin/bash

# Configure advertise and bind addresses so we don't need publish HTTP port from servers
export CLUSTER_CONFIG='advertise {\n  http = "'$NODE_IP'"\n}\n'
export CLUSTER_CONFIG=$CLUSTER_CONFIG'bind_addr = "'$NODE_IP'"\n'
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
