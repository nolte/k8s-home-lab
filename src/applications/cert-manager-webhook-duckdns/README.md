# DuckDNS.org Certmanager Webhook

* thanks to [ebrianne/cert-manager-webhook-duckdns](https://github.com/ebrianne/cert-manager-webhook-duckdns)!

```sh
kubectl -n cert-manager \
 create secret generic duckdns-token \
  --from-literal=token="$(pass internet/duckdns.org/oidc-google/token)"
```