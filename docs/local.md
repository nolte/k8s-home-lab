# Local Dev Env

<!--kind-init-start-->

```sh
task \
  kind:destroy \
  kind:create \
  kind:apply
```

<!--kind-init-end-->


??? abstract "Start the Kind Cluster"
    task: `task kind:create`

??? example "Start port foward"
    ```sh
    kubectl port-forward svc/argocd-server 8080:443 -n argocd
    ```

    ??? example "ArgoCD Password"
        ```yaml
        kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo ""
        ```

    ??? example "ArgoCD CLI Login"
        task: `task argocd:login`

        ```yaml
        argocd login \
          localhost:8080 \
          --username admin \
          --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) \
          --name local-bootstrapper
        ```

??? example "Argo Workflow PortForward"
    ```sh
    kubectl port-forward svc/argo-workflows-server 2746 -n argo
    ```



??? danger "Delete Cluster"
    
    task: `task kind:destroy`

    ```sh
    kind delete cluster --name production
    ```

## Bootstrapping Status

```sh
argo get bootstrap-cluster -n argocd
```


## Terraform 


??? example "Environment variable)"

    ??? example "Vault Access"
        
        Required Vars and Login
        {%
           include-markdown "../src/applications/vault/README.md"
           start="<!--env-vars-start-->"
           end="<!--env-vars-end-->"
        %}


    ??? example "S3 State Backend"

        Planing to use `secrets-tf/services/s3/users/svc-tf-argo`
        {%
           include-markdown "./services/minio.md"
           start="<!--s3-state-tf-env-vars-start-->"
           end="<!--s3-state-tf-env-vars-end-->"
        %}

    ??? example "IAM Keycloak Access"
    

        {%
           include-markdown "./services/keycloak.md"
           start="<!--keycloak-tf-env-vars-start-->"
           end="<!--keycloak-tf-env-vars-end-->"
        %}

```sh
 terragrunt run-all apply --terragrunt-non-interactive
```