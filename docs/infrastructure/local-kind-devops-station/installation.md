# Installation


## Precondition


??? example "Required Manifests"

    ```sh
    argo submit -n argocd \
      --from workflowtemplate/script-argocd-application \
      -p argocd-application-name=bootstrap-screenplay \
      -p argocd-application-project=cicd \
      -p argocd-destination-namespace=argocd \
      -p argocd-source-path="src/clusters/screenplay/dev-kind-powerdns" \
      -p argocd-source-repoURL="https://github.com/nolte/argo-charts.git" \
      -p argocd-source-targetRevision="feature/audio-station"
    ```
    
    ```sh
    argo submit -n argocd \
      --from workflowtemplate/script-argocd-application \
      -p argocd-application-name=seed-job \
      -p argocd-application-project=cicd \
      -p argocd-destination-namespace=argocd \
      -p argocd-source-path="src/bundles/00-bootstrapping-minimal" \
      -p argocd-source-repoURL="https://github.com/nolte/argo-charts.git" \
      -p argocd-source-targetRevision="feature/audio-station"
    ```


## Bootstrapping Status

```sh
argo get bootstrap-cluster -n argocd
```

## Vault Initialisierung


{%
   include-markdown "../../../src/applications/vault/README.md"
   start="<!--vault-init-start-->"
   end="<!--vault-init-end-->"
%}

warten bis die vault Initialisierung abgeschlossen ist,
   
{%
   include-markdown "../../../src/applications/vault/README.md"
   start="<!--vault-init-job-start-->"
   end="<!--vault-init-job-end-->"
%}

## Zertifikate 

[Zertifikate](services/certificates.md#bereitstellung) Bereitstellen 

 