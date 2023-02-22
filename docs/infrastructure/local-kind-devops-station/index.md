# Overview



## Terraform 


??? example "Environment variable)"

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
           include-markdown "../../services/keycloak.md"
           start="<!--keycloak-tf-env-vars-start-->"
           end="<!--keycloak-tf-env-vars-end-->"
        %}

```sh
 terragrunt run-all apply --terragrunt-non-interactive
```