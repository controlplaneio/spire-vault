# Vault PKI Secrets

The PKI Secrets Engine is used as

* An Upstream Certificate Authority for the Spire Server.
* The Certificate provider for the Spire Agents to enable x509pop Node Attestation.

The PKI Secrets engine is configured in [configure-pki-secrets.sh](../vault/configure-pki-secrets.sh)

1. Mount the engine at _spiffe_ and configure.
2. Create a root CA and write the certificate to [ca.pem](../ca.pem) for later use configuring TLS Certificate
authentication.
3. Create a Policy for the Spire Server that allows it to sign intermediate CAs.
4. Create a Role that allows Certificates to be created and a Policy that allows the Spire Agent to create Certificates
using this Role.
