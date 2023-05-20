# Identity- & Access-Management

{%
   include-markdown "../../src/applications/keycloak/README.md"
   start="<!--description-start-->"
   end="<!--description-end-->"
%}

---

{%
   include-markdown "../../src/applications/keycloak/README.md"
   start="<!--header-start-->"
   end="<!--header-end-->"
%}

---


## Usefull Commands

??? example "Start port foward"
    {%
       include-markdown "../../src/applications/keycloak/README.md"
       start="<!--port-forward-start-->"
       end="<!--port-forward-end-->"
    %}

## Usefull Env

??? example "Using Ingress"

    <!--keycloak-tf-env-vars-start-->
    ```sh
    export KEYCLOAK_URL=https://$(kubectl -n keycloak get httpproxies.projectcontour.io keycloak -ojson  | jq '.spec.virtualhost.fqdn' -r) \
        && export KEYCLOAK_USER=$(vault kv get -field=username secrets-tf/services/IdentityAccessManagement/users/admin) \
        && export KEYCLOAK_PASSWORD=$(vault kv get -field=password secrets-tf/services/IdentityAccessManagement/users/admin)
    ```
    <!--keycloak-tf-env-vars-end-->


??? example "Using port foward"

    {%
       include-markdown "../../src/applications/keycloak/README.md"
       start="<!--keycloak-tf-env-vars-port-forward-start-->"
       end="<!--keycloak-tf-env-vars-port-forward-end-->"
    %}

??? example "Open, if httpproxy configured"

    {%
       include-markdown "../../src/applications/keycloak/README.md"
       start="<!--httpproxies-start-->"
       end="<!--httpproxies-end-->"
    %}


## Links

{%
   include-markdown "../../src/applications/keycloak/README.md"
   start="<!--keycloak-links-start-->"
   end="<!--keycloak-links-end-->"
%}