#!/usr/bin/env bash

export VAULT_ADDR=http://localhost:30000
export VAULT_TOKEN=root

vault secrets enable -path spiffe pki
vault secrets tune -max-lease-ttl=8760h spiffe
vault write spiffe/config/urls \
  issuing_certificates="http://$HOST_IP:30000/v1/spiffe/ca" \
  crl_distribution_points="http://$HOST_IP:30000/v1/spiffe/crl"
vault write spiffe/root/generate/internal \
  common_name=controlplane.io \
  key_type=ec \
  key_bits=256 \
  organization=controlplane \
  ou=engineering \
  country=uk
vault write spiffe/roles/spire-server \
  allowed_domains=controlplane.io \
  allow_subdomains=true \
  key_type=ec \
  key_bits=256 \
  max_ttl=8760h
vault write spiffe/roles/spire-agent \
  allowed_domains=controlplane.io \
  allow_subdomains=true \
  key_type=ec \
  key_bits=256 \
  max_ttl=15m
