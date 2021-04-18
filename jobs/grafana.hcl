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
        to = 3000
      }
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:latest"
        ports = ["http"]
      }

      env {
        GF_SERVER_ROOT_URL = "http://${NOMAD_IP_http}:${NOMAD_PORT_http}/grafana"
        GF_SERVER_SERVE_FROM_SUB_PATH = true
      }

      service {
        name = "grafana"
        tags = [
          "monitoring",
          "urlprefix-/grafana",
        ]
        port = "http"
        check {
          type     = "http"
          path     = "/grafana/api/health"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
