# Cluster Bootstrapping

1. Argocd über Helm Apply bereitstellen siehe [Lokaler Cluster](local.md)

    {%
       include-markdown "local.md"
       start="<!--kind-init-start-->"
       end="<!--kind-init-end-->"
    %}

    1. Argo Workflow wird Automatisch vorbereitet mit den ersten Workflows.
    2. Die erste Kombianation von applikationen wird Bereitgestellt. [src/bundles/00-bootstrapping-minimal](./src/bundles/00-bootstrapping-minimal)


2. Vault Init

    {%
       include-markdown "../src/applications/vault/README.md"
       start="<!--vault-init-start-->"
       end="<!--vault-init-end-->"
    %}

3. [Zertifikate](services/certificates.md#bereitstellung) Bereitstellen 

 