<p align="center"><img src="https://i.imgur.com/p1RzXjQ.png"><br></p>
<div align="center">
<a href="https://github.com/nolte/k8s-home-lab"><img src="https://img.shields.io/github/stars/nolte/k8s-home-lab.svg?label=Stars&style=social"></a>
<a href="https://github.com/nolte/k8s-home-lab"><img src="https://img.shields.io/github/issues-raw/nolte/k8s-home-lab.svg"></a>
<a href="https://github.com/nolte/k8s-home-lab/actions/workflows/tf-lint.yaml"><img src="https://github.com/nolte/k8s-home-lab/actions/workflows/tf-lint.yaml/badge.svg"></a>
</div>


# Personal Cluster

This project will be used to create different flavors/collections of services running on Kubernetes.

The basics of the deployment process are [ArgoCD](https://argo-cd.readthedocs.io/en/stable/) for deployment/control of K8S manifests from the repository (SCM) and [Argo Workflow](https://argoproj.github.io/argo-workflows/) as a process automation tool.

## Service Sets

K8S clusters will be configured for different use cases such as [SmartHome](./docs/service-sets/smart-home.md), [DevOps services](./docs/service-sets/devops.md) or private storage.

### Developer Cluster

A combination of services like Secret Management, Git and Container Registry. This setup can be used to manage some basic infrastructure using Infrastructure as Code (IaC) tools.

*(more information at [src/clusters/dev-kind-powerdns](src/clusters/dev-kind-powerdns/README.md))*.   

### Smart Home 

Services for hosting a `cloud-less` smart home system with MQTT Broker, zigbee gateway, Home-Assistant and many more.

*(more information at [src/clusters/smart-home](src/clusters/smart-home/README.md))*

### Monitoring

*(planed)* Monitoring service set, for testing network connections and many more.

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

## Docs

You can use the task alias `task mkdocs:start`, for starting the mkdocs server for local development.

## Local Deploy

```sh
 kustomize build .  --load-restrictor LoadRestrictionsNone | kubectl apply -f -
```

## Links

* For Bootstrapping take a look to [nolte/ansible_playbook-baseline-online-server](https://github.com/nolte/ansible_playbook-baseline-online-server#start-ssh-agent)
* For Install k3s [nolte/ansible_playbook-baseline-k3s](https://github.com/nolte/ansible_playbook-baseline-k3s)
* [nolte/helm-charts-repo](https://github.com/nolte/helm-charts-repo/) as Classic Helm Chart Repository.
* [nolte/taskfiles](https://github.com/nolte/taskfiles), collection of reusable task.
