client {
  enabled = false
}

server {
  enabled = true
  bootstrap_expect = 3
}

tls {
  ca_file = "nomad-agent-ca.pem"
  cert_file = "nomad-server.pem"
  key_file = "nomad-server-key.pem"
}
