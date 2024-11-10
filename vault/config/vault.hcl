ui            = true
disable_mlock = true
log_level     = "Info"

storage "raft" {
    path                   = "/opt/vault/data"
    performance_multiplier = 1
    retry_join {
        leader_api_addr        = "https://node1:8200"
        leader_ca_file         = "/opt/certs/rootca.crt"
        leader_cert_file       = "/opt/certs/nomad-simplified.crt"
        leader_key_file        = "/opt/certs/nomad-simplified.key"
        insecure_skip_verify   = false
    }
    retry_join {
        leader_api_addr        = "https://node2:8200"
        leader_ca_file         = "/opt/certs/rootca.crt"
        leader_cert_file       = "/opt/certs/nomad-simplified.crt"
        leader_key_file        = "/opt/certs/nomad-simplified.key"
        insecure_skip_verify   = false
    }
    retry_join {
        leader_api_addr        = "https://node3:8200"
        leader_ca_file         = "/opt/certs/rootca.crt"
        leader_cert_file       = "/opt/certs/nomad-simplified.crt"
        leader_key_file        = "/opt/certs/nomad-simplified.key"
        insecure_skip_verify   = false
    }
}

listener "tcp" {
    address         = "0.0.0.0:8200"
    tls_cert_file   = "/opt/certs/nomad-simplified.crt"
    tls_key_file    = "/opt/certs/nomad-simplified.key"
    tls_min_version = "tls12"
    telemetry {
        unauthenticated_metrics_access = true
    }
}

service_registration "consul" {
    address = "127.0.0.1:8500"
    service_tags = "admin,vault"
}

telemetry {
    prometheus_retention_time = "24h"
    disable_hostname = false
}

seal "azurekeyvault" {
}
