# Personal Cluster

This Project will be use for creating different flavors/collections of Services, runs on  kubernetes.

Configure k8s cluster for *different UseCases* like, [SmartHome](./docs/service-sets/smart-home.md), [DevOps Services](./docs/service-sets/devops.md) or Private Storage 

The Basement of the delivery process are [ArgoCD]() for Deployment/Control K8S Manifests and [Argo Workflow]() as process automation tool.

## Project Structure

| **Folder**         | **Description**                                                              |
|--------------------|------------------------------------------------------------------------------|
| `docs`             | Folder for [mkdocs](https://www.mkdocs.org/) based documentation.            |
| `hack`             | Useful scripts for local Cluster Bootstrapping.                              |
| `src/applications` | Preconfigured ArgoCD Applications, for deploy different type of Services.    |
| `src/bundles`      | Will Be combine a different set of Services, into one "Product".             |
| `src/clusters`     | Represent the Differnt Clusters with the different Service Set for each one. |

For more Information take a look into the `README.md` inside the Subfolder like [/src/applications](./src/applications/README.md). 

## Links

* For Bootstrapping take a look to [nolte/ansible_playbook-baseline-online-server](https://github.com/nolte/ansible_playbook-baseline-online-server#start-ssh-agent)
* For Install k3s [nolte/ansible_playbook-baseline-k3s](https://github.com/nolte/ansible_playbook-baseline-k3s)
* [nolte/helm-charts-repo](https://github.com/nolte/helm-charts-repo/) as Classic Helm Chart Repository.