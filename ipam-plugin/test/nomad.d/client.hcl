data_dir = "/opt/nomad/data"
disable_update_check = true

client {
  enabled = true
  servers = ["192.0.2.11"]
}

consul {
  client_auto_join = false
}

server {
  enabled = false
}

ui {
  enabled = false
}
