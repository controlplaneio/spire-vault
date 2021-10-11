# Vault Kubernetes Authentication

Kubernetes Authentication is used by

* Spire Server to sign its CA
* Spire Agents to retrieve the x509 Certificate used to attest to the Server

It is configured in [configure-kubernetes-auth.sh](../vault/configure-kubernetes-auth.sh) and the Roles for the Spire
Server and Agent are mapped to the corresponding Service Accounts in the Spire Namespace.
