client {
  enabled = true
  host_volume "host-root" {
    path      = "/"
    read_only = false
  }
}

plugin "docker" {
  config {
    allow_privileged = true
    extra_labels = ["job_name", "task_group_name", "task_name", "namespace", "node_name"]

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

    volumes {
      enabled = false
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
