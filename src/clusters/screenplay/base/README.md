

```
argo submit \
  -n argocd \
  --from workflowtemplate/flow-bump-up-step
```

kustomize build . | kubectl apply -f -