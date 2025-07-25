job "test-dc1" {
  datacenters = ["dc1"]
  namespace = "test1"
  type = "service"

  group "test1" {
    task "test1.test1" {
      service {
        name = "test1"
        provider = "nomad"
        address_mode = "driver"
      }

      driver = "docker"
      config {
        image = "burmilla/debug"
        network_mode = "dc1"
      }
    }
  }
}
