data_dir = "/opt/nomad/data"
disable_update_check = true

client {
  enabled = false
}

consul {
  client_auto_join = false
}

server {
  enabled = true
  bootstrap_expect = 1
}
