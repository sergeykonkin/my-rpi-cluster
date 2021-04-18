job "podinfo" {
  region      = "local"
  datacenters = ["home"]

  group "podinfo" {
    count = 3

    network {
      port "http" {
        to = 9898
      }
    }

    task "podinfo" {
      driver = "docker"

      config {
        image = "stefanprodan/podinfo:latest"
        ports = ["http"]
      }

      service {
        name = "podinfo"
        port = "http"
        tags = [
          "prometheus-scrape",
          "urlprefix-/podinfo/ strip=/podinfo",
        ]
        check {
          type     = "http"
          path     = "/healthz"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
