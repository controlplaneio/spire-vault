server {
  bind_address = "0.0.0.0"
  bind_port = "8081"
//  socket_path = "/tmp/spire-server/private/api.sock"
  trust_domain = "controlplane.io"
  data_dir = "/run/spire/data"
  log_level = "DEBUG"
  ca_key_type = "rsa-4096"
  default_svid_ttl = "1h"
  ca_subject = {
    country = [
      "UK",
    ],
    organization = [
      "ControlPlane",
    ],
    common_name = "ControlPlane",
  }
}

plugins {
  DataStore "sql" {
    plugin_data {
      database_type = "sqlite3"
      connection_string = "/run/spire/data/datastore.sqlite3"
    }
  }

  KeyManager "disk" {
    plugin_data {
      keys_path = "/run/spire/data/keys.json"
    }
  }

  NodeAttestor "x509pop" {
    plugin_data {
      ca_bundle_path = "/run/secrets/ca/ca.pem"
      agent_path_template = "/cn/{{ .Subject.CommonName }}"
    }
  }

  UpstreamAuthority "vault" {
    plugin_data {
      vault_addr = "https://vault.vault.svc:8200"
      insecure_skip_verify = true
      pki_mount_point = "spiffe"
      k8s_auth {
        k8s_auth_role_name = "spire-server"
        token_path = "/var/run/secrets/tokens/vault-token"
      }
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
