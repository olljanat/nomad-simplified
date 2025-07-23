client {
  node_class = "linux"
  options {
    "user.denylist" = "root"
  }
}

data_dir = "/opt/nomad/data"
