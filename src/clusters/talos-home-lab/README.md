# Talos Homelab

<!--cluster-description-start-->

<!--cluster-description-end-->


## Precondition

* Preconfigured Proxmox Infrastructure

## Install

1. Start with `./configuration/tf-infrastructure`
2. `kustomize build --load-restrictor LoadRestrictionsNone . | kubectl apply -f -`
3. Add secrets into the cluster with `./configuration/tf-post-deploy`

## Usage

```sh
export KUBECONFIG=./configuration/tf-infrastructure/output/kube-config.yaml
```