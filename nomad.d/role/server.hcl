client {
  enabled = false
}

server {
  enabled = true
  bootstrap_expect = 3
}

tls {
  ca_file = "/opt/tls/nomad-agent-ca.pem"
  cert_file = "/opt/tls/nomad-server.pem"
  key_file = "/opt/tls/nomad-server-key.pem"
}
