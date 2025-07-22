client {
  node_class = "windows"
  options {
    "user.denylist" = "ContainerAdministrator"
  }
}

data_dir = "c:\\opt\\nomad\\data"

plugin "docker" {
  config {
    # Make sure that ContainerAdmin cannot be used
    # https://github.com/hashicorp/nomad/pull/23443
    windows_allow_insecure_container_admin = false
  }
}
