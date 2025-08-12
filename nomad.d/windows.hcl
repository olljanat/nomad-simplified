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
