agent {
  data_dir = "/run/spire/data"
  log_level = "DEBUG"
  server_address = "spire-server"
  server_port = "8081"
  socket_path = "/run/spire/sockets/agent.sock"
  trust_bundle_path = "/vault/secrets/ca.crt"
  trust_domain = "controlplane.io"
}

plugins {
  KeyManager "disk" {
    plugin_data {
      directory = "/run/spire/data/agent"
    }
  }

  NodeAttestor "x509pop" {
    plugin_data {
      private_key_path = "/vault/secrets/tls.key"
      certificate_path = "/vault/secrets/tls.crt"
    }
  }

  WorkloadAttestor "k8s" {
    plugin_data {
      skip_kubelet_verification = true
    }
  }
}

health_checks {
  listener_enabled = true
  bind_address = "0.0.0.0"
  bind_port = "8080"
  live_path = "/live"
  ready_path = "/ready"
}
