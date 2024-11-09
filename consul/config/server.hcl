ui_config = {
    "enabled"=true
}
server = true
bootstrap_expect = 3
retry_join = ["10.10.10.11","10.10.10.12","10.10.10.13"]
bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
connect {
    enabled = true
}

telemetry {
    "prometheus_retention_time" = "372h"
}
