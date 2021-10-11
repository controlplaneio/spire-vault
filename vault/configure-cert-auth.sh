#!/usr/bin/env bash

export VAULT_SKIP_VERIFY=true
export VAULT_ADDR=https://localhost:30000
export VAULT_TOKEN=$(cat init.json | jq -r .root_token)

vault auth enable cert

vault write auth/cert/certs/spiffe \
  certificate=@ca.pem \
  allowed_common_names=*.controlplane.io \
  allowed_uri_sans=spiffe://controlplane.io/* \
  token_ttl=15m \
  token_max_ttl=1h

rm  ca.pem