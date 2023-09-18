<p align="center"><img src="https://i.imgur.com/p1RzXjQ.png"><br></p>
<div align="center">
<a href="https://github.com/nolte/k8s-home-lab"><img src="https://img.shields.io/github/stars/nolte/k8s-home-lab.svg?label=Stars&style=social"></a>
<a href="https://github.com/nolte/k8s-home-lab"><img src="https://img.shields.io/github/issues-raw/nolte/k8s-home-lab.svg"></a>
<a href="https://github.com/nolte/k8s-home-lab/actions/workflows/tf-lint.yaml"><img src="https://github.com/nolte/k8s-home-lab/actions/workflows/tf-lint.yaml/badge.svg"></a>
</div>


# Personal Cluster

This project will be used to create different flavours/collections of services running on Kubernetes.

K8S clusters will be configured for different use cases such as [SmartHome](./docs/service-sets/smart-home.md), [DevOps services](./docs/service-sets/devops.md) or private storage.

The basics of the deployment process are [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) for deployment/control of K8S manifests from the repository (SCM) and [Argo Workflow](https://argoproj.github.io/argo-workflows/) as a process automation tool.


## Project Structure

<!--structure-start-->
```
.
├─📁 .github          # Github Actions and configurations, like linting etc.
├─📁 .taskfiles       # Taskfiles with Reusable small util commands
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
| `src/clusters`             | Represent the Different Clusters with the different Service Set for each one. |
| `src/kustomization-common` | Reusable Kustomize overlays, like Namespace Handling etc.                   |
| `src/terraground-common`   | Shared Terragrunt Configs, like Statefile Handling or Module Versions.      |
| `src/talos-configs`        | The [Talos](https://www.talos.dev/) K8S Cluster configs.                     |

For more Information take a look into the `README.md` inside the subfolder like [/src/applications](./src/applications/README.md).

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
