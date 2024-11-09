template {
    source = "/opt/consul/templates/agent.key.tpl"
    destination = "/opt/consul/agent-certs/agent.key"
    perms = 0644
}

template {
    source = "/opt/consul/templates/agent.crt.tpl"
    destination = "/opt/consul/agent-certs/agent.crt"
}
