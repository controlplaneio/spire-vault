#!/usr/bin/env bash

export VAULT_SKIP_VERIFY=true
export VAULT_ADDR=https://localhost:30000
export VAULT_TOKEN=$(cat init.json | jq -r .root_token)

vault auth enable kubernetes
vault write auth/kubernetes/config \
  kubernetes_host=https://10.96.0.1 \
  issuer=https://kubernetes.default.svc.cluster.local

vault write auth/kubernetes/role/spire-server \
  bound_service_account_names=spire-server \
  bound_service_account_namespaces=spire \
  policies=spire-server

vault write auth/kubernetes/role/spire-agent \
  bound_service_account_names=spire-agent \
  bound_service_account_namespaces=spire \
  policies=spire-agent
