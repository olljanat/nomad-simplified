acl {
  enabled = true
}

addresses {
  http = "0.0.0.0"
}

client {
  options {
    "driver.allowlist" = "docker"
    "user.checked_drivers" = "docker"
  }
}

consul {
  client_auto_join = false
}

disable_update_check = true

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics = true
  prometheus_metrics = true
}

tls {
  http = false
  rpc = true
  verify_https_client = false
  verify_server_hostname = true
}
