template {
    source = "/opt/vault/data/templates/agent.key.tpl"
    destination = "/opt/vault/tls/agent.key"
    perms = 0644
}

template {
    source = "/opt/vault/data/templates/agent.crt.tpl"
    destination = "/opt/vault/tls/agent.crt"
}
