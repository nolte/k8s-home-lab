# Identity- & Access-Management


## Usefull Env

<!--keycloak-tf-env-vars-start-->
```sh
export KEYCLOAK_URL=https://$(kubectl -n keycloak get httpproxies.projectcontour.io keycloak -ojson  | jq '.spec.virtualhost.fqdn' -r) \
    && export KEYCLOAK_USER=$(vault kv get -field=username secrets-tf/services/IdentityAccessManagement/users/admin) \
    && export KEYCLOAK_PASSWORD=$(vault kv get -field=password secrets-tf/services/IdentityAccessManagement/users/admin)
```
<!--keycloak-tf-env-vars-end-->


## Links

{%
   include-markdown "../../src/applications/keycloak/README.md"
   start="<!--keycloak-links-start-->"
   end="<!--keycloak-links-end-->"
%}