# Overview



## Terraform

For Development it is useful to execute the Terraform scripts from our Local Device.

??? example "Environment variable"

    ??? example "Vault Access"

        Required Vars and Login
        {%
           include-markdown "../../../src/applications/vault/README.md"
           start="<!--env-vars-start-->"
           end="<!--env-vars-end-->"
        %}


    ??? example "S3 State Backend"

        Planing to use `secrets-tf/services/s3/users/svc-tf-argo`
        {%
           include-markdown "../../services/minio.md"
           start="<!--s3-state-tf-env-vars-start-->"
           end="<!--s3-state-tf-env-vars-end-->"
        %}

    ??? example "IAM Keycloak Access"


        {%
           include-markdown "../../../src/applications/keycloak/README.md"
           start="<!--keycloak-tf-env-vars-start-->"
           end="<!--keycloak-tf-env-vars-end-->"
        %}


    ??? example "Harbor Access"


        {%
           include-markdown "../../../src/applications/harbor/README.md"
           start="<!--tf-env-vars-start-->"
           end="<!--tf-env-vars-end-->"
        %}


```sh
 terragrunt run-all apply --terragrunt-non-interactive
```


## Third Party Secrets

??? example "Required Secrets"

    ??? example "Duckdns"

        Used for [duckdns.org](https://www.duckdns.org/), as DNS Service.
        {%
           include-markdown "../../../src/applications/cert-manager-webhook-duckdns/README.md"
           start="<!--vault-secret-start-->"
           end="<!--vault-secret-end-->"
        %}

    ??? example "Github App"

        Used [github.com](https://docs.github.com/en/apps/creating-github-apps/setting-up-a-github-app/creating-a-github-app), as External Identity Provider (IdP), for single sign on with your Personal Account.
        {%
        include-markdown "../../../src/applications/keycloak/README.md"
        start="<!--identity-providers-github-app-vault-start-->"
        end="<!--identity-providers-github-app-vault-end-->"
        %}
