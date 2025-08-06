acl {
  enabled = true
}

client {
  options {
    "driver.allowlist" = "docker"
    "user.checked_drivers" = "docker"
  }
}

disable_update_check = true

plugin "docker" {
  config {
    allow_privileged = false
    extra_labels = ["job_name", "task_group_name", "task_name", "namespace", "node_name"]
    volumes {
      enabled = false
    }

    # Make garbage collector less agressive
    gc {
      container = false
      dangling_containers {
        creation_grace = "30m"
        enabled = true
        period = "2h"
      }
      image = true
      image_delay = "24h"
    }
  }
}

telemetry {
  publish_allocation_metrics = true
  publish_node_metrics = true
  prometheus_metrics = true
}

tls {
  rpc = true
  http = true
  verify_https_client = false
  verify_server_hostname = true
}
