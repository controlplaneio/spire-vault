# Vault Initialisation

In order to utilise TLS Certificate Authentication we need to enable TLS and therefore cannot run Vault in dev mode.

[Cert Manager](https://cert-manager.io/) is deployed and a self signed CA and Certificate are created before deployment
and configured in [values.yaml](../vault/values.yaml).

Vault is then [initialised and unsealed](../vault/init-unseal.sh) with the initialisation response piped to
[init.json](../init.json) and used to unseal, apply further configuration and accessing Vault through the
[NodePort](https://localhost:30000).
