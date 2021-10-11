# Vault Identity

The Spiffe Identities are configured in Vault in [configure-identity.sh](../vault/configure-identity.sh).

1. An Entity is created for the Spiffe ID and Policies attached
2. An Alias is created mapping the common name extracted from the x509 SVID by the TLS Certificate Authentication mount.
