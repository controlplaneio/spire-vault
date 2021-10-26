# Demo

## Prereqs

```shell
export KUBECONFIG=kubeconfig
export VAULT_SKIP_VERIFY=true
export VAULT_ADDR=https://localhost:30000
make infra
```

## Configure Vault

```shell
make configure-vault
export VAULT_TOKEN=$(cat init.json | jq -r .root_token)
```

## PKI Secrets Engine

View root ca certificate

```shell
openssl x509 -text -noout -in <(curl -k https://localhost:30000/v1/spiffe/ca/pem)
```

## TLS Cert Authentication

View the certificate

```shell
openssl x509 -text -noout -in <(vault read -field=certificate auth/cert/certs/spiffe)
```

Certs issued by spire can now authenticate to vault

## Identity Configuration

Show entities

```shell
vault read identity/entity/name/controlplane.io/workload/svc-a
vault read identity/entity/name/controlplane.io/workload/svc-b
```

Show entity aliases

```shell
for i in $(vault list -format json identity/entity-alias/id | jq -r .[]); do
    vault read /identity/entity-alias/id/$i
done
```

## Deploy Spire and Workloads

```shell
make deploy-spire deploy-workloads
```

### Spire Server

View policy that allows spire server to sign it's key.

```shell
vault policy read spire-server
```

View spire configuration

```shell
cat spire/config/kind/server/server.hcl
```

### Spire Agent

View policy that allows agents to get x509 certificates to attest to spire

```shell
vault policy read spire-agent
```

View the configured role

```shell
vault read spiffe/roles/spire-agent
```

View agent configuration

```shell
kubectl -n spire exec -c vault-agent $(kubectl -n spire  get po -l=app.kubernetes.io/component=agent -oname) -- \
  cat /home/vault/config.json | jq
```

```shell
cat spire/config/kind/agent/agent.hcl
```



## Register the workloads and get x509 SVIDs

```shell
make register-workloads
make fetch-svids
```

View x509 SVID

```shell
kubectl exec $(kubectl get po -l=app.kubernetes.io/name=svc-a -oname) -- \
  cat /tmp/svid.0.pem
```

Got the workload certificate and the spire server's certificate so can build the chain of trust

```shell
openssl x509 -text -noout -in <(kubectl exec $(kubectl get po -l=app.kubernetes.io/name=svc-a -oname) -- cat /tmp/svid.0.pem)
```

## Login to Vault

```shell
make login-vault-svc-a
make login-vault-svc-b
```
