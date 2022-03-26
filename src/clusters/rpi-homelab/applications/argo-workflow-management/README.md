# Script Based Workflows

## Precondition

```
kubectl -n rpi-homelab-management create secret generic git-creds-inventory \
  --from-literal=id_rsa="$(pass internet/github.com/deployment-keys/ansible-inventories/id_rsa)" \
  --from-literal=id_rsa.pub="$(pass internet/github.com/deployment-keys/ansible-inventories/id_rsa.pub)" \
  --from-literal=known_hosts="$(ssh-keyscan -t rsa github.com)"
```

```
kubectl -n rpi-homelab-management create secret generic ansible-ssh \
  --from-literal=id_rsa="$(pass private/keyfiles/ssh/internal/internal_rsa)" \
  --from-literal=id_rsa.pub="$(pass private/keyfiles/ssh/internal/internal_rsa.pub)" \
  --from-literal=known_hosts="$(ssh-keyscan -t rsa github.com)"
```

```
kubectl -n rpi-homelab-management create secret generic git-creds \
  --from-literal=id_rsa="$(pass internet/project/homeassistant/deploymentkey/id_rsa)" \
  --from-literal=id_rsa.pub="$(pass internet/project/homeassistant/deploymentkey/id_rsa.pub)" \
  --from-literal=known_hosts="$(ssh-keyscan -t rsa github.com)"
```