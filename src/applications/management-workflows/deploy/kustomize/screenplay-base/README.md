# Bootstrap Screenplay

<!--intro-start-->
Workflows for change seed job configuration step by step. This give a better controll over depdendencies between deployments.
<!--intro-end-->

## Usage

<!--usage-start-->
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

<!--cmd-submit-start-->
```sh
argo submit \
  -n argocd \
  --from workflowtemplate/flow-bump-up-step \
  --parameter configmapname=<screenplay-configmap-name>
```
<!--cmd-submit-end-->

<!--usage-end-->

## Development

```sh
kustomize build . | kubectl apply -f -
```
