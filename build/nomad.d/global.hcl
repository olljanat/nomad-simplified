client {
    enabled = true
    options {
        "driver.allowlist" = "docker"
        "env.denylist" = "CONSUL_ENCRYPT_KEY,AZURE_CLIENT_SECRET"
        "user.denylist" = "ContainerAdministrator"
    }
}

consul {
    address = "https://127.0.0.1:8501"
}

plugin "docker" {
  config {
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
    http = true
    rpc = true
    verify_https_client = false
}
