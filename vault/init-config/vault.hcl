listener "unix" {
  address = "/run/vault.sock"
}

storage "raft" {
  path    = "/opt/vault/data"
}

seal "azurekeyvault" {
}
