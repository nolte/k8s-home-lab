# Bootstrap Screenplay

Workflows for change seed job configuration step by step. This give a better controll over depdendencies between deployments.

## Usage

Required a config map with the expected deployment "way/steps".

```yaml
apiVersion: v1
kind: ConfigMap
data:
  state.0.path: ./src/bundles/00-bootstrapping-minimal
  state.1.path: ./src/bundles/05-bootstrapping-ingress
  state.2.path: ./src/bundles/10-bootstrapping-utils
...
```


Start the Workflow:

```sh
argo submit \
  -n argocd \
  --from workflowtemplate/flow-bump-up-step \
  --parameter configmapname=screenplay-minimal
```

## Development

```sh
kustomize build . | kubectl apply -f -
```
