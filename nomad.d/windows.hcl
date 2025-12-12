addresses {
  http = "127.0.0.1"
}

client {
  enabled = true
}

data_dir = "c:\\opt\\nomad\\data"

log_level = "INFO"
log_file = "c:\\logs\\nomad.log"
log_rotate_bytes = 1048576
log_rotate_duration = "24h"
log_rotate_max_files = 100

plugin "docker" {
  config {
    disable_log_collection = true
    extra_labels = ["job_name", "task_group_name", "task_name", "namespace", "node_name"]

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

    volumes {
      enabled = false
    }
  }
}

server {
  enabled = false
}

tls {
  ca_file = "c:\\opt\\tls\\nomad-agent-ca.pem"
  cert_file = "c:\\opt\\tls\\nomad-client.pem"
  key_file = "c:\\opt\\tls\\nomad-client-key.pem"
}
