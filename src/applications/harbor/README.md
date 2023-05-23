# Harbor

<!--port-forward-start-->
```sh
kubectl -n harbor port-forward svc/harbor-portal 8080:80 
```
<!--port-forward-end-->





```sh
export HARBOR_INSECURE=true \
  && export HARBOR_PASSWORD=$(kubectl get secrets -n harbor harbor-core -ojson | jq '.data.HARBOR_ADMIN_PASSWORD' -r | base64 -d) \
  && export HARBOR_USERNAME=admin \
  && export HARBOR_ENDPOINT=harbor.dev44-just-homestyle.duckdns.org
```

<!--reset-admin-password-by-api-start-->
```sh 
curl -k -X PUT \
  -u ${HARBOR_USERNAME}:${HARBOR_PASSWORD} \
  "https://${HARBOR_ENDPOINT}/api/v2.0/users/1/password" \
  -H "accept: application/json" \
  -H "Content-Type: application/json" \
  -d "{ \"new_password\": \"Harbor123456\", \"old_password\": \"${HARBOR_PASSWORD}\"}"

```
<!--reset-admin-password-by-api-end-->


