job "grafana" {
  region      = "local"
  datacenters = ["home"]
  type        = "service"

  group "grafana" {
    count = 1

    ephemeral_disk {
      migrate = true
      sticky  = true
    }

    network {
      port  "http" {
        static = 3000
        to = 3000
      }
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:latest"
        ports = ["http"]
      }

      service {
        name = "grafana"
        tags = ["monitoring"]
        port = "http"
        check {
          type     = "http"
          path     = "/api/health"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
