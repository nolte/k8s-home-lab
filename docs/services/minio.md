# Minio


## Usefull Commands

??? example "Start port foward"
    ```sh
    kubectl -n operators port-forward svc/console 9090
    
    # or
    https://minio-console.smart-home.k8sservices.local
    ```

??? example "Access"

    *JWT Token:*
    ```sh
      kubectl -n operators \
        get secret $(kubectl -n operators get serviceaccount console-sa -o jsonpath="{.secrets[0].name}") \
        -o jsonpath="{.data.token}" | base64 --decode
    ```


<!--s3-state-tf-env-vars-start-->
```sh
export AWS_S3_ENDPOINT=https://$(kubectl -n minio get httpproxies.projectcontour.io minio -ojson  | jq '.spec.virtualhost.fqdn' -r) \
    && export AWS_ACCESS_KEY_ID=$(vault kv get -field=accesskey secrets-tf/services/s3/users/admin) \
    && export AWS_SECRET_ACCESS_KEY=$(vault kv get -field=secretkey secrets-tf/services/s3/users/admin)
```
<!--s3-state-tf-env-vars-end-->

## Links/Open Tasks

* SSO Integration 
