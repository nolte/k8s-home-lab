# Script Based Workflows

## Ansible Playbooks

### Precondition

```
kubectl -n argocd create secret generic git-creds-inventory \
  --from-literal=id_rsa="$(pass internet/github.com/deployment-keys/ansible-inventories/id_rsa)" \
  --from-literal=id_rsa.pub="$(pass internet/github.com/deployment-keys/ansible-inventories/id_rsa.pub)" \
  --from-literal=known_hosts="$(ssh-keyscan -t rsa github.com)"
```

```
kubectl -n argocd create secret generic ansible-ssh \
  --from-literal=id_rsa="$(pass private/keyfiles/ssh/internal/internal_rsa)" \
  --from-literal=id_rsa.pub="$(pass private/keyfiles/ssh/internal/internal_rsa.pub)" \
  --from-literal=known_hosts="$(ssh-keyscan -t rsa github.com)"
```

### Usage

```
argo submit -n argocd \
  --from clusterworkflowtemplate/script-ansible \
  -p inventory-path="src/local" \
  -p inventory-repo="git@github.com:nolte/ansible-inventories.git" \
  -p inventory-revision="develop" \
  -p playbook="playbook-firewalld-stop.yaml" \
  -p playbook-repo="git@github.com:nolte/ansible_playbook-baseline-k3s.git" \
  -p playbook-revision="feature/controllable-firelld" 
```

```
argo submit -n argocd \
  --from clusterworkflowtemplate/script-ansible \
  -p inventory-path="src/local" \
  -p inventory-repo="git@github.com:nolte/ansible-inventories.git" \
  -p inventory-revision="develop" \
  -p playbook="playbook-install-k3s.yaml" \
  -p playbook-repo="git@github.com:nolte/ansible_playbook-baseline-k3s.git" \
  -p playbook-revision="feature/controllable-firelld" 
```