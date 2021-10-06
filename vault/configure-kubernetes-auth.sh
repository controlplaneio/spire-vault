#!/usr/bin/env bash

export VAULT_ADDR=http://localhost:30000
export VAULT_TOKEN=root

vault auth enable kubernetes
vault write auth/kubernetes/config \
  kubernetes_host=https://10.96.0.1 \
  issuer=https://kubernetes.default.svc.cluster.local
vault write auth/kubernetes/role/spire-server \
  bound_service_account_names=spire-server \
  bound_service_account_namespaces=spire \
  policies=spire-server
vault policy write spire-server -<<EOF
path "spiffe/root/sign-intermediate" {
  capabilities = [
    "update",
  ]
}
EOF

vault write auth/kubernetes/role/spire-agent \
  bound_service_account_names=spire-agent \
  bound_service_account_namespaces=spire \
  policies=spire-agent
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
