template {
    source = "/etc/vault.d/templates/agent.key.tpl"
    destination = "/opt/vault/tls/agent.key"
    perms = 0644
}

template {
    source = "/etc/vault.d/templates/agent.crt.tpl"
    destination = "/opt/vault/tls/agent.crt"
}
