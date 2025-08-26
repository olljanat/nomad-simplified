bind = "0.0.0.0"
port = 443
tls {
  cert_file = "/opt/tls/nomad-nacp.pem"
  key_file = "/opt/tls/nomad-nacp-key.pem"
  ca_file = "/opt/tls/nomad-nacp-ca.pem"
  no_client_cert = true
}

nomad {
  address = "http://127.0.0.1:4646"
}

telemetry {
  logging {
    type = "slog"
    level = "info" # debug, info, warn, error
    slog {
      handler = "text"
    }
  }
  metrics {
    enabled = false
  }
  tracing {
    enabled = false
  }
}

validator "opa" "job_opa_validator" {
  opa_rule {
    query = <<EOH
    errors = data.job.errors
    EOH
    filename = "/etc/nacp/validators/job.rego"
  }
}
