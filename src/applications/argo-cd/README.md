# ArgoCD

<!--description-start-->
keeps the cluster in sync ...
<!--description-end-->

<!--header-start-->
**Deployment:** Helm, [argoproj/argo-helm](https://github.com/argoproj/argo-helm/tree/main/charts/argo-cd)  
**Web**: [argo-cd](https://argo-cd.readthedocs.io/en/stable/)  
<!--header-end-->


<!--port-forward-start-->
```sh
kubectl port-forward svc/argocd-server 8080:443 -n argocd
```
<!--port-forward-end-->


## Access

<!--admin-password-start-->
```sh
kubectl -n argocd \
    get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d \
    && echo ""
```
<!--admin-password-end-->

<!--cli-admin-login-start-->
```sh
argocd login \
  localhost:8080 \
  --username admin \
  --password $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d) \
  --name local-bootstrapper
```
<!--cli-admin-login-end-->
