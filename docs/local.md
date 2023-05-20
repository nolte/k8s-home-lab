# Local Environment

The local environment will be used as temporary Boostrapping/Management Cluster.

<!--kind-init-start-->

```sh
task \
  kind:destroy \
  kind:create \
  kind:apply_bootstrapping
```

<!--kind-init-end-->

After this, you will be get a preconfigured ArgoCD and ArgoWorkflow deployment, used for manage different sets of Services/Clusters.

??? abstract "Starter Sets"

    [Task](https://github.com/go-task/task) Steps, for starting with preconfigured set of Services.

    | **Task Goal**          | **Chart Config**                      | **Kurz Beschreibung**                                                                                                                                                                                                                   |
    |------------------------|---------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
    | `apply`                | `-`                                   | Ein "blanker" Kind Cluster mit ArgoCD, dieses setting dient als Grundlage aller Kind Deployments.                                                                                                                                       |
    | `apply_devops_station` | `values-kind-deployments.yaml`        | Breitstellung eines Vollständig Konfigurierten DevOps Clusters mit diversen unterstützenden Tools wie z.B. Vault, Harbor etc.                                                                                                           |
    | `apply_monitoring`     | `values-kind-monitoring-node.yaml`    | Bereitstellung einer Minimal Installation der Monitoring Komponenten. Dieses Deployment wird genutzt um den eigenen Hausanschluss zu überwachen, und eventuelle geschwindigkeits Verluste frühzeitig zu bemerken und zu protokollieren. |
    | `apply_bootstrapping`  | `values-kind-bootstrapping-node.yaml` | Stellt ein Minimales set an Services bereit, ArgoCD und Argo Workflow bilden hier die Grundlage für weitere Installationen.                                                                                                             |   

    **Deprecated** Please try to use allways `kind:apply_bootstrapping` and after this you can install the required Resources like [rpiCluster](./infrastructure/rpi-cluster/installation.md) or [Kind DevOpsStation](./infrastructure/local-kind-devops-station/installation.md), by submit some ArgoWorkflow.


??? example "Start port foward"
    {%
       include-markdown "../src/applications/argo-cd/README.md"
       start="<!--port-forward-start-->"
       end="<!--port-forward-end-->"
    %}

    ??? example "ArgoCD Password"
        {%
           include-markdown "../src/applications/argo-cd/README.md"
           start="<!--admin-password-start-->"
           end="<!--admin-password-end-->"
        %}

    ??? example "ArgoCD CLI Login"
        task: `task argocd:login`

        {%
           include-markdown "../src/applications/argo-cd/README.md"
           start="<!--cli-admin-login-start-->"
           end="<!--cli-admin-login-end-->"
        %}        

??? example "Argo Workflow PortForward"
    ```sh
    kubectl port-forward svc/argo-workflows-server 2746 -n argo
    ```



??? danger "Delete Cluster"
    
    task: `task kind:destroy`

    ```sh
    kind delete cluster --name production
    ```

For deploy the Different Clusters/Service sets, take a look to: 

* [RPI HomeLab](./infrastructure/rpi-cluster/index.md) *(RPI Based Cluster for Smart Home, and useful other services.)*
* [Kind DevOps Station](./infrastructure/local-kind-devops-station/installation.md) *(Cluster for Hosting devopment and maintenance services, like Vault, Gitea etc.)*