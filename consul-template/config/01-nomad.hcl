template {
    source = "/etc/nomad.d/templates/agent.crt.tpl"
    destination = "/etc/nomad.d/agent-certs/agent.crt"
    perms = 0700
}

template {
    source = "/etc/nomad.d/templates/agent.key.tpl"
    destination = "/etc/nomad.d/agent-certs/agent.key"
    perms = 0700
}

template {
    source = "/etc/nomad.d/templates/ca.cert.tpl"
    destination = "/etc/nomad.d/agent-certs/ca.crt"
}

template {
    source = "/etc/nomad.d/templates/cli.crt.tpl"
    destination = "/etc/nomad.d/cli-certs/cli.crt"
}

template {
    source = "/etc/nomad.d/templates/cli.key.tpl"
    destination = "/etc/nomad.d/cli-certs/cli.key"
}
