KUBECONFIG ?= ./kubeconfig

SHELL := /bin/bash

.EXPORT_ALL_VARIABLES:

#
# Kind
#

all: create-cluster deploy-cert-manager deploy-vault configure-vault deploy-spire deploy-workloads

.PHONY: infra
infra: create-cluster deploy-cert-manager deploy-vault

.PHONY: create-cluster delete-cluster

create-cluster:
	kind create cluster --name spire-vault --config kind.yaml
	kubectl create ns vault
	kubectl create ns spire

delete-cluster:
	kind delete cluster --name spire-vault

#
# Cert Manager
#

.PHONY: deploy-cert-manager

deploy-cert-manager:
	kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml

#
# Vault
#

.PHONY: deploy-vault delete-vault configure-vault

deploy-vault:
	sleep 5
	kubectl -n cert-manager wait --for=condition=Ready --timeout=60s \
		$$(kubectl -n cert-manager get po -l=app.kubernetes.io/component=webhook -oname)
	kubectl apply -k vault/certs
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm install vault hashicorp/vault -n vault -f vault/values.yaml --wait

delete-vault:
	helm uninstall vault -n vault
	kubectl delete -k vault/certs
	kubectl -n vault delete pvc data-vault-0

configure-vault:
	./vault/init-unseal.sh
	./vault/configure-kubernetes-auth.sh
	./vault/configure-pki-secrets.sh
	./vault/configure-cert-auth.sh
	./vault/configure-identity.sh

display-ca-crt:
	openssl x509 -in <(curl -k https://localhost:30000/v1/spiffe/ca/pem) -text -noout

#
# Spire
#

.PHONY: logs-spire-server logs-spire-agent

deploy-spire-%:
	kubectl apply -k spire/config/kind/$*

deploy-spire: deploy-spire-server deploy-spire-agent

delete-spire-%:
	kubectl delete -k spire/config/kind/$*

logs-spire-server:
	kubectl -n spire logs -l=app.kubernetes.io/component=server

logs-spire-agent:
	kubectl -n spire logs -l=app.kubernetes.io/component=agent -c spire-agent

#
# Workload
#

deploy-workload-%:
	kubectl apply -k workload/config/kind/$*

deploy-workloads: deploy-workload-svc-a deploy-workload-svc-b

delete-workload-%:
	kubectl delete -k workload/config/kind/$*

delete-workloads: delete-workload-svc-a delete-workload-svc-b

register-workload-%:
	kubectl exec -n spire $$(kubectl -n spire get po -l=app.kubernetes.io/component=server -oname) \
		-c spire-server -- \
		/opt/spire/bin/spire-server entry create \
		-spiffeID spiffe://controlplane.io/workload/$* \
		-parentID spiffe://controlplane.io/spire/agent/cn/spire-agent.controlplane.io \
		-dns $*.controlplane.io \
		-selector k8s:ns:default \
		-selector k8s:sa:$*

register-workloads: register-workload-svc-a register-workload-svc-b

healthcheck-%:
	kubectl exec $$(kubectl get po -l=app.kubernetes.io/name=$* -oname) -- \
		./bin/spire-agent healthcheck -socketPath /spire-agent-socket/agent.sock

fetch-svid-%: ## creates /tmp/{svid.0.key,svid.0.pem,bundle.0.pem}
	kubectl exec $$(kubectl get po -l=app.kubernetes.io/name=$* -oname) -- \
		./bin/spire-agent api fetch -socketPath /spire-agent-socket/agent.sock -write /tmp

fetch-svids: fetch-svid-svc-a fetch-svid-svc-b

login-vault-%:
	kubectl exec $$(kubectl get po -l=app.kubernetes.io/name=$* -oname) -- apk add openssl curl jq
	kubectl exec $$(kubectl get po -l=app.kubernetes.io/name=$* -oname) -- curl -k \
	  --cert /tmp/svid.0.pem \
	  --key /tmp/svid.0.key \
	  --data '{"name": "spiffe"}' \
	  https://vault.vault.svc:8200/v1/auth/cert/login | jq
