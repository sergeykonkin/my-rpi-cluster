job "grafana" {
  region      = "local"
  datacenters = ["home"]
  type        = "service"

  group "grafana" {
    count = 1

    volume "grafana" {
      type      = "host"
      source    = "grafana"
      read_only = false
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

      volume_mount {
        volume      = "grafana"
        destination = "/var/lib/grafana"
        read_only   = false
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
