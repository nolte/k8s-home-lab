# ArgoCD Workflows


## Usage

```sh
argo submit -n argocd \
  --from workflowtemplate/script-argocd-application \
  -p argocd-application-name=bootstrap-screenplay \
  -p argocd-application-project=cicd \
  -p argocd-destination-namespace=argocd \
  -p argocd-source-path="src/clusters/screenplay/dev-kind-powerdns" \
  -p argocd-source-repoURL="https://github.com/nolte/argo-charts.git" \
  -p argocd-source-targetRevision="master"
```
