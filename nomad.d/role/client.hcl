addresses {
  http = "127.0.0.1"
}

client {
  enabled = true
  drain_on_shutdown {
    deadline = "2m"
    force = true
    ignore_system_jobs = true
  }
}

leave_on_interrupt = true
leave_on_terminate = true

server {
  enabled = false
}

tls {
  http = false
  ca_file = "/opt/tls/nomad-agent-ca.pem"
  cert_file = "/opt/tls/nomad-client.pem"
  key_file = "/opt/tls/nomad-client-key.pem"
}

ui {
  enabled = false
}
