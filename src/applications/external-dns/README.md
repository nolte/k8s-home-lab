# ExternalDNS

<!--description-start-->

<!--description-end-->

<!-- vale off -->
<!--header-start-->
**Deployment:** [bitnami/external-dns]https://artifacthub.io/packages/helm/bitnami/external-dns)
**Web**: [kubernetes-sigs/external-dns](https://github.com/kubernetes-sigs/external-dns/)  
<!--header-end-->
<!-- vale on -->


<!--preconditions-esphome-config-start-->
```sh
kubectl -n external-dns create secret generic pihole-config \
  --from-literal=pihole_password="admin" 
```
<!--preconditions-esphome-config-end-->



Used a PowerDNS based setup.

```sh
export PDNS_API_KEY=supersecretpw
export PDNS_API_URL=http://localhost:8081
curl -H "X-API-Key: ${PDNS_API_KEY}" ${PDNS_API_URL}/api/v1/servers/localhost/zones/smart-home.k8sservices.local. | jq '.rrsets[] | select(.name | contains("echo"))'
```

* [bitnami/external-dns](https://github.com/bitnami/charts/blob/master/bitnami/external-dns/README.md)
