# DuckDNS.org Certmanager Webhook

* thanks to [ebrianne/cert-manager-webhook-duckdns](https://github.com/ebrianne/cert-manager-webhook-duckdns)!

<!--workflow-deploy-start-->
```sh
argo submit \
  -n argocd \
  --from workflowtemplate/app-cert-manager-webhook-duckdns \
  -p issuerEmail=$(pass internet/letsencrypt/account_mail) \
  -p externalsecrets-enabled=true 
```
<!--workflow-deploy-end-->
## Preconditions

Create the Duckdns Token by hand,
<!--classic-secret-start-->
```sh
kubectl -n cert-manager \
 create secret generic duckdns-token \
  --from-literal=token="$(pass internet/duckdns.org/oidc-google/token)"
```
<!--classic-secret-end-->

or if you use a the Secret Management System add the token to Vault.

<!--vault-secret-start-->
```sh
vault kv put \
  secrets-tf/third-party-services/duckdns.org/api \
  token=$(pass internet/duckdns.org/oidc-google/token)
```
<!--vault-secret-end-->

## Links

* https://github.com/ebrianne/helm-charts/tree/master/charts/cert-manager-webhook-duckdns
* https://github.com/ebrianne/cert-manager-webhook-duckdns