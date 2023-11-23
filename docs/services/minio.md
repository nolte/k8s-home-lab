# MinIO

{%
   include-markdown "../../src/applications/minio/README.md"
   start="<!--description-start-->"
   end="<!--description-end-->"
%}

---

{%
   include-markdown "../../src/applications/minio/README.md"
   start="<!--header-start-->"
   end="<!--header-end-->"
%}

---

## Useful Commands

### Control

??? example "Start port forward"
    ```sh
    kubectl -n operators port-forward svc/console 9090
    ```

??? example "Access"

    *JWT Token:*
    ```sh
      kubectl -n operators \
        get secret $(kubectl -n operators get serviceaccount console-sa -o jsonpath="{.secrets[0].name}") \
        -o jsonpath="{.data.token}" | base64 --decode
    ```



### Tenant


??? example "Start port forward"
    ```sh
    kubectl -n minio port-forward svc/minio 9000:80
    ```

<!--s3-state-tf-env-vars-port-forward-start-->
```sh
export AWS_S3_ENDPOINT=http://localhost:9000/ \
    && export AWS_ACCESS_KEY_ID=$(vault kv get -field=accesskey secrets-tf/services/s3/users/admin) \
    && export AWS_SECRET_ACCESS_KEY=$(vault kv get -field=secretkey secrets-tf/services/s3/users/admin)
```
<!--s3-state-tf-env-vars-port-forward-end-->

<!--s3-state-tf-env-vars-start-->
```sh
export AWS_S3_ENDPOINT=https://$(kubectl -n minio get httpproxies.projectcontour.io minio -ojson  | jq '.spec.virtualhost.fqdn' -r) \
    && export AWS_ACCESS_KEY_ID=$(vault kv get -field=accesskey secrets-tf/services/s3/users/admin) \
    && export AWS_SECRET_ACCESS_KEY=$(vault kv get -field=secretkey secrets-tf/services/s3/users/admin)
```
<!--s3-state-tf-env-vars-end-->


```sh
export MINIO_ENDPOINT=$(kubectl -n minio get httpproxies.projectcontour.io minio -ojson  | jq '.spec.virtualhost.fqdn' -r) \
    && export MINIO_ACCESS_KEY=$(vault kv get -field=accesskey secrets-tf/services/s3/users/admin) \
    && export MINIO_SECRET_KEY=$(vault kv get -field=secretkey secrets-tf/services/s3/users/admin)
```

## Links/Open Tasks

* SSO Integration
