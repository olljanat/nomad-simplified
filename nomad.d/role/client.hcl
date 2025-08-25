client {
  enabled = true
}

plugin "docker" {
  config {
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
