# Vault TLS Certificate Authentication

Vault TLS Certificate Authentication is used, in conjunction with the [Identity Secrets Engine](vault-identity.md) to
enable workloads to login to Vault using the x509 SVIDs obtained from Vault.

The mount is configured with the CA Certificate created when enabling the [PKI Secrets Engine](vault-pki-secrets.md)
previously.

The x509 SVID issued by Spire contains the Workload's Certificate and the Spire Server's Certificate so Vault is able to
establish the train of trust.
