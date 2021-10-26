#!/usr/bin/env bash

export VAULT_SKIP_VERIFY=true
export VAULT_ADDR=https://localhost:30000
export VAULT_TOKEN=$(cat init.json | jq -r .root_token)

CERT_ACCESSOR=$(vault auth list -format=json | jq -r '."cert/".accessor')

for i in svc-a svc-b; do
  ID=$(vault write -field=id identity/entity name=controlplane.io/workload/$i policies=$i)
  vault write identity/entity-alias name="$i.controlplane.io" \
    canonical_id=$ID \
    mount_accessor=$CERT_ACCESSOR
done
