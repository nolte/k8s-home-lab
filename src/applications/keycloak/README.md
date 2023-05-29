# Keycloak
<!--description-start-->
Identity and access management solution.
<!--description-end-->


<!--header-start-->
**Namespace:** `keycloak`  
**Configuration:** `./src/applications/keycloak/configuration/baseline`  
**Deployment:** Helm, [bitnami/keycloak](https://github.com/bitnami/charts/tree/main/bitnami/keycloak/)  
**Terraform Provider:** [mrparkers/keycloak](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs)  
**Web:** [keycloak.org](https://www.keycloak.org/)
<!--header-end-->

## Usefull Commands

<!--port-forward-start-->
```sh
kubectl -n keycloak port-forward svc/keycloak 8081:80
```
<!--port-forward-end-->

open [localhost:8081](http://localhost:8081)



<!--keycloak-tf-env-vars-port-forward-start-->
```sh
export KEYCLOAK_URL=http://localhost:8081 \
    && export KEYCLOAK_USER=$(vault kv get -field=username secrets-tf/services/IdentityAccessManagement/users/admin) \
    && export KEYCLOAK_PASSWORD=$(vault kv get -field=password secrets-tf/services/IdentityAccessManagement/users/admin)
```
<!--keycloak-tf-env-vars-port-forward-end-->

<!--keycloak-tf-env-vars-start-->
```sh
export KEYCLOAK_URL=https://$(kubectl -n keycloak get httpproxies.projectcontour.io http-proxy -ojson  | jq '.spec.virtualhost.fqdn' -r) \
    && export KEYCLOAK_USER=$(vault kv get -field=username secrets-tf/services/IdentityAccessManagement/users/admin) \
    && export KEYCLOAK_PASSWORD=$(vault kv get -field=password secrets-tf/services/IdentityAccessManagement/users/admin)
```
<!--keycloak-tf-env-vars-end-->


```sh
argo -n keycloak get post-sync-keycloak
```

open [Workflow](http://localhost:2746/workflows/keycloak/post-sync-keycloak?tab=workflow)


<!--keycloak-links-start-->
* [keycloak.org](https://www.keycloak.org/)
* [terraform provider](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client)
* [Gitlab as IdP](https://medium.com/keycloak/github-as-identity-provider-in-keyclaok-dca95a9d80ca)

<!--keycloak-links-end-->


**Open HttpProxy if exists**
<!--httpproxies-start-->
```sh
browse \
  "https://$(kubectl -n keycloak get httpproxies.projectcontour.io http-proxy -ojson | jq '.spec.virtualhost.fqdn' -r)"
```
<!--httpproxies-end-->

## External OIDC Identity Provider

For Sign in with your Personal Accounts we use Github as External Identity Provider (IdP).

<!--identity-providers-github-app-vault-start-->
```sh
vault kv put \
  secrets-tf/third-party-services/github.com/nolte/apps/k8s-home-lab \
  client_secret=$(pass internet/github.com/nolte/apps/k8s-home-lab/client_secret) \
  client_id=$(pass internet/github.com/nolte/apps/k8s-home-lab/client_id)
```
<!--identity-providers-github-app-vault-end-->
