# Spire Vault

Example configuration for integrating [Spire](https://spiffe.io/docs/latest/spire-about/) with
[Vault](https://www.vaultproject.io/).

* Using Vault as an Upstream CA for the Spire Server.
* Using Vault to issue x509 Certificates to Spire Agents for Node Attestation.
* Using Spire issued x509 SVIDs for Workloads to login to Vault.

## Steps

1. Bring up the custer and deploy everything
2. Register the workloads
3. Login to vault

```shell
make all
make register-workloads
make login-vault-svc-a
```

Cleanup

```shell
make delete-cluster
```
