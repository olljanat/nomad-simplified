client {
  enabled = true
  options {
    "driver.allowlist" = "docker"
    "user.denylist" = "root,ContainerAdministrator"
  }
}

consul {
  address = "https://127.0.0.1:8501"
  verify_ssl = false
  server_service_name = "nomad"
  client_service_name = "nomad-client"
  auto_advertise = true
  server_auto_join = true
  client_auto_join = true
}

plugin "docker" {
  config {
  allow_privileged = false
  allow_caps = [""]
  volumes {
    enabled = false
  }
  }
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics = true
  prometheus_metrics = true
}

# tls {
#   http = false
#   rpc = false
#   verify_server_hostname = false
# }
