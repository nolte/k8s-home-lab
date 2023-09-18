# DuckDNS.org Certmanager Webhook

* thanks to [ebrianne/cert-manager-webhook-duckdns](https://github.com/ebrianne/cert-manager-webhook-duckdns)!

```sh
argo submit \
  -n argocd \
  --from workflowtemplate/app-cert-wildcard \
  -p name-prefix=rpi- \
  -p destination-name=rpi \
  -p cert-wildcard-dns-name=rpi-just-homestyle.duckdns.org

```
