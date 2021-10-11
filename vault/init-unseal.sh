#!/usr/bin/env bash

set -e

kubectl wait -n vault --for=condition=Initialized --timeout=60s pod/vault-0 && sleep 10
kubectl -n vault exec -it vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > init.json
kubectl -n vault exec -it vault-0 -- vault operator unseal $(cat init.json | jq -r .unseal_keys_b64[0])
