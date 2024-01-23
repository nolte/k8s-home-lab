# Vault

<!--description-start-->
API Based Secret Management
<!--description-end-->


<!--header-start-->
**Namespace:** `vault`  
**Configuration:** `./src/applications/vault/configuration`  
**Deployment:** [hashicorp/vault-helm](https://github.com/hashicorp/vault-helm)  
**Terraform Provider:** [hashicorp/vault](https://registry.terraform.io/providers/hashicorp/vault/latest/docs)  
**Web:** [Vaultproject.io](https://www.vaultproject.io/)  
<!--header-end-->

## User Access

*Access Configuration:* `./src/applications/keycloak/configuration`

more information at the [keycloak](/services/keycloak/) page

## Useful Commands

**Port Forward**
<!--port-forward-start-->
```sh
kubectl -n vault port-forward svc/vault 8200
```
<!--port-forward-end-->

**Open HttpProxy if exists**
<!--httpproxies-start-->
```sh
browse \
  "https://$(kubectl -n vault get httpproxies.projectcontour.io http-proxy -ojson | jq '.spec.virtualhost.fqdn' -r)"
```
<!--httpproxies-end-->




??? example "Root Token"

    Submit workflow for unseal Vault

    ```sh
    argo submit \
      --from workflowtemplate/vault-flow-unseal \
      --serviceaccount argo-workflow -n argo-workflow \
      -p AWS_ACCESS_KEY_ID=$(kubectl -n minio get secrets minio -ojson | jq '.data.accesskey' -r | base64 -d)     \
      -p AWS_SECRET_ACCESS_KEY=$(kubectl -n minio get secrets minio -ojson | jq '.data.secretkey' -r | base64     -d)
    ```

    ```sh
    kubectl -n vault delete secrets vault-init-tokens
    ```

    Show Root Token from Secret:

    ```sh
    kubectl -n vault get secrets vault-init-tokens -ojson | jq '.data["content.json"]' -r | base64 -d | sed     -En "s/root_token: (.*)/\1/p" | xargs
    ```


## Links/Open Tasks

* User Permissions


```sh
export KUBE_CONFIG_PATH=~/.kube/config

```



### Initial

For the Initial deployment you must generate the Root Token an some unseal keys.


<!--vault-init-start-->
```sh
gopass insert -m -f \
  private/services/vault.just-homestyle.duckdns.org/root  <<<$(kubectl exec -n vault -ti vault-0 -- vault operator init -format=json)
```

```sh
kubectl exec \
  -n vault \
  -ti vault-0 -- vault operator unseal $(gopass private/services/vault.just-homestyle.duckdns.org/root | jq '.unseal_keys_b64[0]' -r) \
  && kubectl exec \
    -n vault \
    -ti vault-0 -- vault operator unseal $(gopass private/services/vault.just-homestyle.duckdns.org/root | jq '.unseal_keys_b64[1]' -r) \
  && kubectl exec \
    -n vault \
    -ti vault-0 -- vault operator unseal $(gopass private/services/vault.just-homestyle.duckdns.org/root | jq '.unseal_keys_b64[2]' -r)
```

```sh
kubectl create secret generic -n vault vault-initial-keys \
  --from-literal "root_token=$(gopass private/services/vault.just-homestyle.duckdns.org/root | jq '.root_token' -r)"
```
<!--vault-init-end-->

<!--vault-init-job-start-->
```sh
 argo -n vault wait @latest  
```
<!--vault-init-job-end-->

### Useful Environment Variables

port-forward

<!--env-vars-port-forward-start-->
```sh
export VAULT_ADDR=http://localhost:8200 \
    && vault login token=$(gopass private/services/vault.just-homestyle.duckdns.org/root | jq '.root_token' -r)
```
<!--env-vars-port-forward-end-->

<!--env-vars-start-->
```sh
export VAULT_ADDR=https://$(kubectl -n vault get httpproxies.projectcontour.io http-proxy -ojson  | jq '.spec.virtualhost.fqdn'  -r) \
    && vault login token=$(gopass private/services/vault.just-homestyle.duckdns.org/root | jq '.root_token' -r)
```
<!--env-vars-end-->


<!--login-port-forward-start-->
```sh
export VAULT_ADDR=http://localhost:8200 \
    && vault login token=$(gopass private/services/vault.just-homestyle.duckdns.org/root | jq '.root_token' -r)
```
<!--login-port-forward-end-->

## Links

* [integrate-keycloak-with-hashicorp-vault](https://faun.pub/integrate-keycloak-with-hashicorp-vault-5264a873dd2f)
