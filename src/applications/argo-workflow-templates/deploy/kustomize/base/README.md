# Base Steps


## TF Exec

```sh
argo submit \
  -n argocd \
  --from clusterworkflowtemplate/flow-tf-exec \
  -p repo=https://github.com/nolte/argo-charts.git \
  -p action="run-all apply" \
  -p path=./hack/terraground-example \
  -p revision=master
```