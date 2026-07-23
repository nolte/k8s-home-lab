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
