client {
  node_class = "linux"
  options {
    "user.denylist" = "root"
  }
}

consul {
  address = "http://127.0.0.1:8500"
}

data_dir = "/opt/nomad/data"
