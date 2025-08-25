acl {
  enabled = true
}

addresses {
  http = "127.0.0.1"
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

plugin "docker" {
  config {
    allow_privileged = false
    extra_labels = ["job_name", "task_group_name", "task_name", "namespace", "node_name"]
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

tls {
  http = false
  rpc = true
  verify_https_client = false
  verify_server_hostname = true
}
