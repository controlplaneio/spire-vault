# Spire Vault

Example configuration for integrating [Spire](https://spiffe.io/docs/latest/spire-about/) with
[Vault](https://www.vaultproject.io/).

* Vault has a Spiffe Root CA
* the Spire server uses Vault as an
[Upstream Authority]https://github.com/spiffe/spire/blob/v1.0.2/doc/plugin_server_upstreamauthority_vault.md to sign
it's root certificate
* the Spire server and agent use x509 Certificates issued by Vault for Node Attestation
  * [server](https://github.com/spiffe/spire/blob/v1.0.2/doc/plugin_server_upstreamauthority_vault.md)
  * [agent](https://github.com/spiffe/spire/blob/v1.0.2/doc/plugin_agent_nodeattestor_x509pop.md)

Launch the Kind cluster and deploy Vault

```shell
make create-cluster deploy-vault
```

Wait for Vault to come up and then configure Vault and launch Spire server and agent

```shell
make configure-vault deploy-spire-server deploy-spire-agent
```

The agent will attest to the server and get the id `spiffe://controlplane.io/spire/agent/cn/spire-agent.controlplane.io`

Cleanup

```shell
make delete-cluster
```
