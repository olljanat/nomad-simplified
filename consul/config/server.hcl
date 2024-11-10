ui_config = {
    "enabled"=true
}
server = true
bootstrap_expect = 3
retry_join = ["node1","node2","node3"]
bind_addr = "{{GetInterfaceIP \"eth0\"}}"
client_addr = "0.0.0.0"
connect {
    enabled = true
}

telemetry {
    "prometheus_retention_time" = "372h"
}
