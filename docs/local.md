# Local Environment

The local environment will be used as temporary Boostrapping/Management Cluster.

<!--kind-init-start-->

```sh
task \
  platform:recreate
```

<!--kind-init-end-->

After this, you will be get a preconfigured ArgoCD and ArgoWorkflow deployment, used for manage different sets of Services/Clusters.

??? abstract "Starter Sets"

    [Task](https://github.com/go-task/task) Steps, for starting with preconfigured set of Services.

    | **Task Goal**                        | **Description**                                                                                                 |
    |--------------------------------------|-----------------------------------------------------------------------------------------------------------------|
    | `platform:serviceset-minnimal`       | Create a minimal pre-configured cluster, with Monitoring Components an some other tools.                        |
    | `platform:serviceset-devops-station` | Create a full configured Developer Platform with Secret Management, Container Registry and many other Services. |
    | `platform:serviceset-smart-home`     | Install Smart Home Components like Eventbus, Homeassistant, ESPHome, and other Stuff.                           |

??? example "Start port forward"
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
    {%
       include-markdown "../src/applications/argo-workflows/README.md"
       start="<!--port-forward-start-->"
       end="<!--port-forward-end-->"
    %}


??? danger "Delete Cluster"

    task: `task platform:kind:destroy`

    ```sh
    kind delete cluster --name production
    ```

For deploy the Different Clusters/Service sets, take a look to:

* [RPI HomeLab](./infrastructure/rpi-cluster/index.md) *(RPI Based Cluster for Smart Home, and useful other services.)*
* [Kind DevOps Station](./infrastructure/local-kind-devops-station/installation.md) *(Cluster for Hosting devopment and maintenance services, like Vault, Gitea etc.)*
