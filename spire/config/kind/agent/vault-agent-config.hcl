pid_file = "/home/vault/.pid"

vault {
  address = "https://vault.vault.svc:8200"
  tls_skip_verify = "true"
}

auto_auth {
  method "kubernetes" {
    mount_path = "auth/kubernetes"
    config = {
      role = "spire-agent"
      token_path = "/var/run/secrets/tokens/vault-token"
    }
  }
}

template {
  contents = "{{- with secret \"spiffe/issue/spire-agent\" \"common_name=spire-agent.controlplane.io\" \"ttl=15m\" -}}{{ .Data.private_key }}{{- end }}"
  destination = "/vault/secrets/tls.key"
}

template {
  contents = "{{- with secret \"spiffe/issue/spire-agent\" \"common_name=spire-agent.controlplane.io\" \"ttl=15m\" -}}{{ .Data.certificate }}{{- end }}"
  destination = "/vault/secrets/tls.crt"
}

template {
  contents = "{{- with secret \"spiffe/issue/spire-agent\" \"common_name=spire-agent.controlplane.io\" \"ttl=15m\" -}}{{ .Data.issuing_ca }}{{- end }}"
  destination = "/vault/secrets/ca.crt"
}
