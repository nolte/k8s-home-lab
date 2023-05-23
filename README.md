# Personal Cluster

This Project will be use for creating different flavors/collections of Services, runs on  kubernetes.

Configure k8s cluster for *different UseCases* like, [SmartHome](./docs/service-sets/smart-home.md), [DevOps Services](./docs/service-sets/devops.md) or Private Storage 

The Basement of the delivery process are [ArgoCD]() for Deployment/Control K8S Manifests and [Argo Workflow]() as process automation tool.



## Project Structure

<!--structure-start-->
```
.
├─📁 .github          # (optional) Sources for configure the Application, mostly with Terraform
├─📁 .taskfiles       # Folder with k8s manifests
├─📁 docs             # The Required Files for the mkdocs based Documentation  
├─📁 hack             # The Sources for configure the Local Bootstrapping Cluster
├─📁 src              # All required Sources for manage the Cluster
└─📝 README.md        # The Application Specific Readme, used as Service Documentation.
```
<!--structure-end-->


| **Folder**                 | **Description**                                                              |
|----------------------------|------------------------------------------------------------------------------|
| `docs`                     | Folder for [mkdocs](https://www.mkdocs.org/) based documentation.            |
| `hack`                     | Useful scripts for local Cluster Bootstrapping.                              |
| `src/applications`         | Preconfigured ArgoCD Applications, for deploy different type of Services.    |
| `src/bundles`              | Will Be combine a different set of Services, into one "Product".             |
| `src/clusters`             | Represent the Differnt Clusters with the different Service Set for each one. |
| `src/kustomization-common` | Reuseable Kustomize overlays, like Namespace Handling etc.                   |
| `src/terraground-common`   | Shared Terraground Configs, like Statefile Handling or Module Versions.      |
| `src/talos-configs`        | The [Talos](https://www.talos.dev/) K8S Cluster configs.                     |

For more Information take a look into the `README.md` inside the Subfolder like [/src/applications](./src/applications/README.md). 

## Docs

```sh
docker run \
    -ti --rm \
    --name mkdocs \
    -p 9000:9000 \
    -e "ADD_MODULES=mkdocs-include-markdown-plugin pymdown-extensions mkdocs-material" \
    -e "LIVE_RELOAD_SUPPORT=true" \
    -e "FAST_MODE=true" \
    -e "DOCS_DIRECTORY=/mydocs" \
    -e "AUTO_UPDATE=true" \
    -e "UPDATE_INTERVAL=1" \
    -e "DEV_ADDR=0.0.0.0:9000" \
    -v $(pwd):/mydocs \
    polinux/mkdocs
```

or you will be use the task alias `task docs`, for starting the mkdocs Container.


### Local Deploy

```sh
 kustomize build .  --load-restrictor LoadRestrictionsNone | kubectl apply -f - 
```

## Links

* For Bootstrapping take a look to [nolte/ansible_playbook-baseline-online-server](https://github.com/nolte/ansible_playbook-baseline-online-server#start-ssh-agent)
* For Install k3s [nolte/ansible_playbook-baseline-k3s](https://github.com/nolte/ansible_playbook-baseline-k3s)
* [nolte/helm-charts-repo](https://github.com/nolte/helm-charts-repo/) as Classic Helm Chart Repository.

