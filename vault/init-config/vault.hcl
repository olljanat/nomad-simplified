cluster_name  = "vault"
cluster_addr  = "https://127.0.0.1:8201"
api_addr      = "https://127.0.0.1:8200"

storage "raft" {
  path    = "/opt/vault/data"
}

listener "tcp" {
    address         = "127.0.0.1:8200"
    cluster_address = "127.0.0.1:8201"
    tls_cert_file   = "/opt/certs/nomad-simplified.crt"
    tls_key_file    = "/opt/certs/nomad-simplified.key"
    tls_min_version = "tls12"
}

seal "azurekeyvault" {
}
