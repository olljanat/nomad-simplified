client_addr = "0.0.0.0"

acl {
  enabled = true
  enable_token_persistence = true
}

ports {
  grpc = -1
  grpc_tls = 8503
  dns  = 8600
  http = -1
  https = 8500
}

telemetry {
  prometheus_retention_time = "720h"
}

tls {
  defaults{
    verify_incoming = false
    verify_outgoing = false
    verify_server_hostname = false
  }
}

ui_config = {
  "enabled"=true
}
