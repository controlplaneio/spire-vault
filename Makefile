SHELL := /bin/bash

KUBECONFIG ?= ./kubeconfig

HOST_IP := $(shell hostname -I | cut -d' ' -f1)

.EXPORT_ALL_VARIABLES:

.PHONY: create-cluster delete-cluster

#
# Kind
#

create-cluster:
	kind create cluster --name spire-vault --config kind.yaml
	kubectl create ns vault
	kubectl create ns spire

delete-cluster:
	kind delete cluster --name spire-vault

#
# Vault
#

deploy-vault:
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm install vault hashicorp/vault -n vault -f vault/values.yaml --wait

delete-vault:
	helm uninstall vault -n vault

configure-vault:
	./vault/configure-kubernetes-auth.sh
	./vault/configure-pki-secrets.sh

display-ca-crt:
	openssl x509 -in <(curl http://localhost:30000/v1/spiffe/ca/pem) -text -noout

#
# Spire Server
#

deploy-spire-server:
	kubectl apply -k spire/config/kind/server

delete-spire-server:
	kubectl delete -k spire/config/kind/server

logs-spire-server:
	kubectl -n spire logs $$(kubectl -n spire get po -l=app.kubernetes.io/component=server -oname)

#
# Spire Agent
#

deploy-spire-agent:
	kubectl apply -k spire/config/kind/agent

delete-spire-agent:
	kubectl delete -k spire/config/kind/agent

logs-spire-agent:
	kubectl -n spire logs -c spire-agent $$(kubectl -n spire get po -l=app.kubernetes.io/component=agent -oname)
