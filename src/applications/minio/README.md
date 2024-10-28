# Minio


<!--description-start-->
Self Hosted S3 Storage
<!--description-end-->


<!--header-start-->
**Namespace:** `minio`  
**Deployment:**  
**Terraform Provider:** [aminueza/minio](https://registry.terraform.io/providers/aminueza/minio/latest/docs)  
**Web:** [min.io](https://min.io/)  
<!--header-end-->

## User Access


Load Access Key and Secret Key direct from the k8s secret `minio-creds-secret`.

```sh
export AWS_ACCESS_KEY_ID=$(kubectl -n minio get secrets minio-creds-secret -ojson | jq -r '.data.secretkey' | base64 -d)

export AWS_SECRET_ACCESS_KEY=$(kubectl -n minio get secrets minio-creds-secret -ojson | jq -r '.data.accesskey' | base64 -d)
```

```sh
export MINIO_USER=minioadmin \
 && export MINIO_PASSWORD=minioadmin
```


```sh
export MINIO_ENDPOINT=localhost:9090 \
    && export MINIO_ACCESS_KEY=$(kubectl -n minio get secrets minio-creds-secret -ojson | jq -r '.data.secretkey' | base64 -d) \
    && export MINIO_SECRET_KEY=$(kubectl -n minio get secrets minio-creds-secret -ojson | jq -r '.data.accesskey' | base64 -d)
``



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



## Useful Commands

**Port Forward**
<!--port-forward-start-->
```sh
kubectl -n minio port-forward svc/minio-hl 9000
```
<!--port-forward-end-->
