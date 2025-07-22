client {
  enabled = true
}

consul {
  client_auto_join = false
}

server {
  enabled = false
}

tls {
  ca_file = "/opt/tls/nomad-agent-ca.pem"
  cert_file = "/opt/tls/nomad-client.pem"
  key_file = "/opt/tls/nomad-client-key.pem"
}

ui {
  enabled = false
}
