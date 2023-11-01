# Minio Tenant


kubectl -n minio create secret generic db-user-pass \
    --from-literal=username=admin \
    --from-literal=password='S!B\*d$zDsb='

helm create minio-tenant
