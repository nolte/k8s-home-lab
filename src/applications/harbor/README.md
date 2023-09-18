# Harbor

<!--description-start-->
Container Registry by [Harbor](https://github.com/goharbor).
<!--description-end-->

<!--header-start-->
**Deployment:** Helm, [goharbor/harbor-helm](https://github.com/goharbor/harbor-helm)  
**Configuration:** `./src/applications/harbor/configuration/baseline`  
**Terraform Provider:** [goharbor/harbor](https://registry.terraform.io/providers/goharbor/harbor/latest)  
**Web**:  [goharbor.io](https://goharbor.io/)
<!--header-end-->


**Open HttpProxy if exists**
<!--httpproxies-start-->
```sh
browse \
  "https://$(kubectl -n harbor get httpproxies.projectcontour.io http-proxy -ojson | jq '.spec.virtualhost.fqdn' -r)"
```
<!--httpproxies-end-->



<!--port-forward-start-->
```sh
kubectl -n harbor port-forward svc/harbor-portal 8080:80
```
<!--port-forward-end-->

<!--tf-env-vars-start-->
```sh
export HARBOR_INSECURE=true \
  && export HARBOR_PASSWORD=$(kubectl get secrets -n harbor harbor-core -ojson | jq '.data.HARBOR_ADMIN_PASSWORD' -r | base64 -d) \
  && export HARBOR_USERNAME=admin \
  && export HARBOR_URL=https://$(kubectl -n harbor get httpproxies.projectcontour.io http-proxy -ojson | jq '.spec.virtualhost.fqdn' -r)"
```
<!--tf-env-vars-end-->

<!--reset-admin-password-by-api-start-->
```sh
curl -k -X PUT \
  -u ${HARBOR_USERNAME}:${HARBOR_PASSWORD} \
  "${HARBOR_URL}/api/v2.0/users/1/password" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d "{ \"new_password\": \"Harbor123456\", \"old_password\": \"${HARBOR_PASSWORD}\"}"

```
<!--reset-admin-password-by-api-end-->
