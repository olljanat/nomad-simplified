client_addr = "0.0.0.0"
verify_incoming = true
verify_outgoing = true
verify_server_hostname = true

acl {
  enabled = true
  enable_token_persistence = true
}

connect {
  enabled = true
}

ports {
  grpc = -1
  grpc_tls = 8503
  dns  = 8600
  http = -1
  https = 8500
}

telemetry {
  prometheus_retention_time = 720h
}

ui_config = {
  "enabled"=true
}

