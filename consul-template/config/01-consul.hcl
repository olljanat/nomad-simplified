template {
    source = "/etc/consul.d/templates/agent.key.tpl"
    destination = "/opt/consul/agent-certs/agent.key"
    perms = 0644
}

template {
    source = "/etc/consul.d/templates/agent.crt.tpl"
    destination = "/opt/consul/agent-certs/agent.crt"
}
