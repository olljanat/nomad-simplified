addresses {
  http = "127.0.0.1"
}

client {
  enabled = true
  options {
    "user.denylist" = "ContainerAdministrator"
  }
}

data_dir = "c:\\opt\\nomad\\data"

log_level = "INFO"
log_file = "c:\\logs\\nomad.log"
log_rotate_bytes = 1048576
log_rotate_duration = "24h"
log_rotate_max_files = 100

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

      # Completely disable image cleanup in Windows
      # these images are big and slow to download again
      image = false
    }

    pull_activity_timeout = "15m"

    # Make sure that ContainerAdmin cannot be used
    # https://github.com/hashicorp/nomad/pull/23443
    windows_allow_insecure_container_admin = false
  }
}

server {
  enabled = false
}

tls {
  http = false
  ca_file = "c:\\opt\\tls\\nomad-agent-ca.pem"
  cert_file = "c:\\opt\\tls\\nomad-client.pem"
  key_file = "c:\\opt\\tls\\nomad-client-key.pem"
}
