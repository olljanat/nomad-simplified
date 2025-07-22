client {
  enabled = true
}

server {
  enabled = false
}

tls {
  ca_file = "nomad-agent-ca.pem"
  cert_file = "nomad-client.pem"
  key_file = "nomad-client-key.pem"
}
