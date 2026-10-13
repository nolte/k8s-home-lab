# Kamerplanter

```
FERNET_KEY
ERASURE_TOMBSTONE_SALT
INTERNAL_SERVICE_TOKEN
ARANGO_ROOT_PASSWORD: dein-sicheres-passwort
ARANGODB_PASSWORD: dein-sicheres-passwort
JWT_SECRET_KEY: dev-only-not-for-production-secret-key-1234
POSTGRES_PASSWORD: foba123456
VECTORDB_PASSWORD: foba123456



# NOTE: FERNET_KEY must be a valid Fernet key = 32 raw bytes url-safe-base64
# encoded (44 chars). `openssl rand -hex 32` produces a 64-char HEX string,
# which Fernet rejects ("Fernet key must be 32 url-safe base64-encoded bytes")
# and the backend then 500s on any encryption path (e.g. weather providers).
# Fallback without python-cryptography: $(openssl rand -base64 32 | tr '+/' '-_')
kubectl create secret generic kamerplanter-secrets \
    --from-literal=ARANGODB_PASSWORD=dein-sicheres-passwort \
    --from-literal=ARANGO_ROOT_PASSWORD=dein-sicheres-passwort \
    --from-literal=JWT_SECRET_KEY=dev-only-not-for-production-secret-key-1234 \
    --from-literal=POSTGRES_PASSWORD=foba123456 \
    --from-literal=VECTORDB_PASSWORD=foba123456 \
    --from-literal=FERNET_KEY=$(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())") \
    --from-literal=ERASURE_TOMBSTONE_SALT=$(openssl rand -hex 32) \
    --from-literal=INTERNAL_SERVICE_TOKEN=$(openssl rand -hex 32)

## Delivery check (hop 4)

`deploy/delivery-check/` carries an hourly in-cluster CronJob that compares the
chart version the ArgoCD `Application` **declares** (`targetRevision`) against
the one the running workloads were actually **rendered from** (`helm.sh/chart`),
and against whether that rendering reached every pod.

It closes `nolte/kamerplanter#1236`. `check_deployed_build.py` in the application
repository (#1318) answers the other half — "does the pod run what its chart
pins" — and is run on demand from a workstation. Neither subsumes the other:
if ArgoCD never applies the *new* chart, the chart version #1318 measures is the
old one and everything is consistently old.

See `deploy/delivery-check/README.md` for what it can and cannot see, the
three-answer contract it keeps, and how it alerts.
