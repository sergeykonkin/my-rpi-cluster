job "prometheus" {
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
        static = 9090
        to = 9090
      }
    }

    task "prometheus" {
      driver = "docker"

      config {
        image = "prom/prometheus:latest"
        ports = ["http"]
        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]
      }

      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"

        data = <<EOH
---
global:
  scrape_interval:     15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'nomad'
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
    consul_sd_configs:
      - server: '{{ env "NOMAD_IP_http" }}:8500'
        services: ['nomad-client', 'nomad']
    relabel_configs:
      - source_labels: ['__meta_consul_tags']
        regex: '(.*)http(.*)'
        action: keep

  - job_name: 'consul_sd'
    consul_sd_configs:
      - server: '{{ env "NOMAD_IP_http" }}:8500'
        datacenter: home
        tags: ['prometheus-scrape']
    relabel_configs:
      - source_labels: ['__meta_consul_service']
        regex:         '(.*)'
        target_label:  'job'
        replacement:   '$1'
EOH
      }

      service {
        name = "prometheus"
        tags = ["monitoring"]
        port = "http"
        check {
          type     = "http"
          path     = "/-/healthy"
          interval = "2s"
          timeout  = "2s"
        }
      }
    }
  }
}
