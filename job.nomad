job "app-monitor" {
  datacenters = ["us-west-1a", "us-west-1c"]
  type = "service"

  constraint {
    attribute = "${node.class}"
    operator = "="
    value = "mgmt"
  }

  vault {
    policies = ["secret-mgmt"]
  }

  group "monitor" {
    task "monitor" {
      driver = "docker"
      leader = true
      config {
        image = "goldstar/mobile-app-monitor:latest"
        force_pull = true
      }

      template {
        data = <<EOF
{{ with secret "secret/data/mgmt/mgmt/mobile-app-monitor/config" }}{{ range $k, $v := .Data.data }}
{{ $k }}={{ $v | toJSON -}}
{{ end }}{{ end }}
EOF
        destination = "secrets/env"
        env = true
      }

      resources {
        cpu    = 100
        memory = 256
      }
    }
  }
}
