# PowerDNS

<!--description-start-->
Private DNS Service
<!--description-end-->


<!--header-start-->
**Namespace:** `powerdns`  
**Configuration:** `./src/applications/powerdns/configuration/baseline`  
**Deployment:** Helm, [k8s-at-home/powerdns](https://github.com/k8s-at-home/charts/tree/master/charts/stable/powerdns/) *(deprecated)*  
**Terraform Provider:** [pan-net/powerdns](https://registry.terraform.io/providers/pan-net/powerdns/latest/docs)  
**Web:** [powerdns.com](https://www.powerdns.com/)
<!--header-end-->


**Port Forward:**

<!--port-forward-start-->
```sh
kubectl -n powerdns port-forward svc/powerdns-webserver 8081
```
<!--port-forward-end-->

<!--pdns-zone-elements-start-->
```sh
export PDNS_API_KEY=$(vault kv get -field token secrets-tf/services/dns/users/root) \
  && export PDNS_SERVER_URL=http://localhost:8081
```

```sh
curl -X GET \
  ${PDNS_SERVER_URL}/api/v1/servers/localhost/zones/smart-home.k8sservices.local. \
  -H "x-api-key: ${PDNS_API_KEY}"
```
<!--pdns-zone-elements-end-->
