# Script Based Workflows

<!--maintenance-description-start-->

For installation and maintenance, mostly implemented with [Ansible](https://www.ansible.com/). As execution layer we use a preconfigured Argo Workflows, with some ClusterWorkflowTemplates, like call Ansible Playbooks from Git. 

* [nolte/ansible_playbook-baseline-online-server](https://github.com/nolte/ansible_playbook-baseline-online-server), for baseline Installation. 
* [nolte/ansible_playbook-baseline-k3s](https://github.com/nolte/ansible_playbook-baseline-k3s), for install the [k3s](https://k3s.io/) based Cluster.
* *(private)* A extra Repository with your Ansible Inventory. 

<!--maintenance-description-end-->

## Precondition

For Github SSH Access, we need a set of Git Repository specific [deployment keys](https://docs.github.com/en/developers/overview/managing-deploy-keys#deploy-keys). 

*Inventory Project Deployment Key.*
<!--preconditions-git-creds-inventory-start-->
```
kubectl -n rpi-homelab-management create secret generic git-creds-inventory \
  --from-literal=id_rsa="$(pass internet/github.com/deployment-keys/ansible-inventories/id_rsa)" \
  --from-literal=id_rsa.pub="$(pass internet/github.com/deployment-keys/ansible-inventories/id_rsa.pub)" \
  --from-literal=known_hosts="$(ssh-keyscan -t rsa github.com)"
```
<!--preconditions-git-creds-inventory-end-->

*SSH Key, used for internal ssh support.*

<!--preconditions-ansible-ssh-start-->
```
kubectl -n rpi-homelab-management create secret generic ansible-ssh \
  --from-literal=id_rsa="$(pass private/keyfiles/ssh/internal/internal_rsa)" \
  --from-literal=id_rsa.pub="$(pass private/keyfiles/ssh/internal/internal_rsa.pub)"
```
<!--preconditions-ansible-ssh-end-->

## Start

<!--maintenance-job-install-start-->
```sh
argo submit -n rpi-homelab-management \
  --from workflowtemplate/infra-install-k3s
```
<!--maintenance-job-install-end-->