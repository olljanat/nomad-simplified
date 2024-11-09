ui            = true
disable_mlock = true
log_level     = "Info"

storage "raft" {
    path                   = "/opt/vault/data"
    performance_multiplier = 1
    retry_join {
        leader_api_addr        = "https://vault1:8200"
        leader_ca_file         = "/usr/local/share/ca-certificates/vault/vault_intermediate_cert.crt"
        leader_cert_file       = "/opt/vault/tls/agent.crt"
        leader_key_file        = "/opt/vault/tls/agent.key"
        insecure_skip_verify   = false
    }
    retry_join {
        leader_api_addr        = "https://vault2:8200"
        leader_ca_file         = "/usr/local/share/ca-certificates/vault/vault_intermediate_cert.crt"
        leader_cert_file       = "/opt/vault/tls/agent.crt"
        leader_key_file        = "/opt/vault/tls/agent.key"
        insecure_skip_verify   = false
    }
    retry_join {
        leader_api_addr        = "https://vault3:8200"
        leader_ca_file         = "/usr/local/share/ca-certificates/vault/vault_intermediate_cert.crt"
        leader_cert_file       = "/opt/vault/tls/agent.crt"
        leader_key_file        = "/opt/vault/tls/agent.key"
        insecure_skip_verify   = false
    }
}

listener "tcp" {
    address         = "0.0.0.0:8200"
    tls_cert_file   = "/opt/vault/tls/agent.crt"
    tls_key_file    = "/opt/vault/tls/agent.key"
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
