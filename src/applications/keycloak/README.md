# Keycloak

*Namespace:* `keycloak`  
*Configuration:* `./src/applications/keycloak/configuration/baseline`  



## Usefull Commands

<!--port-forward-start-->
```sh
kubectl -n keycloak port-forward svc/keycloak-http 8081:80
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


```sh
argo -n keycloak get post-sync-keycloak 
```

open [Workflow](http://localhost:2746/workflows/keycloak/post-sync-keycloak?tab=workflow)


<!--keycloak-links-start-->
* [keycloak.org](https://www.keycloak.org/)
* [terraform provider](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/openid_client)


<!--keycloak-links-end-->


