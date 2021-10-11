#!/usr/bin/env bash

export VAULT_SKIP_VERIFY=true
export VAULT_ADDR=https://localhost:30000
export VAULT_TOKEN=$(cat init.json | jq -r .root_token)

vault secrets enable -path spiffe pki
vault secrets tune -max-lease-ttl=8760h spiffe
vault write spiffe/config/urls \
  issuing_certificates="https://$HOST_IP:30000/v1/spiffe/ca" \
  crl_distribution_points="https://$HOST_IP:30000/v1/spiffe/crl"

vault write -field certificate spiffe/root/generate/internal \
  common_name=controlplane.io \
  key_type=ec \
  key_bits=256 \
  organization=controlplane \
  ou=engineering \
  country=uk > ca.pem

vault policy write spire-server -<<EOF
path "spiffe/root/sign-intermediate" {
  capabilities = [
    "update",
  ]
}
EOF

vault write spiffe/roles/spire-agent \
  allowed_domains=controlplane.io \
  allow_subdomains=true \
  key_type=ec \
  key_bits=256 \
  max_ttl=15m

vault policy write spire-agent -<<EOF
path "spiffe/issue/spire-agent" {
  capabilities = [
    "update",
  ]
  allowed_parameters = {
    "*" = []
    "common_name" = [
      "spire-agent.controlplane.io"
    ]
  }
}
EOF
