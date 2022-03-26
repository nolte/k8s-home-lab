# ArgoCD Workflows


**RPI HomeLab Cluster**

```sh
argo submit -n argocd \
  --from workflowtemplate/script-argocd-application \
  -p argocd-application-name=rpi-management \
  -p argocd-destination-namespace=rpi-homelab-management \
  -p argocd-source-path="src/clusters/rpi-homelab" \
  -p argocd-source-repoURL="https://github.com/nolte/argo-charts.git" \
  -p argocd-source-targetRevision="feature/audio-station"
```

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