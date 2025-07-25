job "test2-dc1" {
  datacenters = ["dc1"]
  namespace = "test1"
  type = "service"
  group "test2" {
    task "test2.test2" {
      service {
        name = "test2"
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
