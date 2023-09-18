

```
argo submit \
  -n argocd \
  --from workflowtemplate/flow-bump-up-step
```

```sh
kustomize build . | kubectl apply -f -
```
