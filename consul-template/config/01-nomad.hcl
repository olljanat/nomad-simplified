template {
    source = "/opt/nomad/templates/agent.crt.tpl"
    destination = "/opt/nomad/agent-certs/agent.crt"
    perms = 0700
}

template {
    source = "/opt/nomad/templates/agent.key.tpl"
    destination = "/opt/nomad/agent-certs/agent.key"
    perms = 0700
}

template {
    source = "/opt/nomad/templates/ca.cert.tpl"
    destination = "/opt/nomad/agent-certs/ca.crt"
}

template {
    source = "/opt/nomad/templates/cli.crt.tpl"
    destination = "/opt/nomad/cli-certs/cli.crt"
}

template {
    source = "/opt/nomad/templates/cli.key.tpl"
    destination = "/opt/nomad/cli-certs/cli.key"
}
