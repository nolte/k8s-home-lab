# Applications

This subdirectory will give the Structure for all Used Application/Services, and the Configuration.

## Application Structure

<!--structure-start-->
```
📁 [application]      # Folder with Required Sources for the Application
├─📁 configuration    # (optional) Sources for configure the Application, mostly with Terraform
| ├─📁 baseline       # The Base Configuration from the Application
| ├─📁 modules        # (optional) Strucuture for Application Specific Terraform Modules
| └─📁 ...            # additional config scripts
|─📁 deploy           # Folder with k8s manifests
| └─📁 argocd         # ArgoCD manifests, required for Deploy the Application to K8S Cluster.
└─📝 README.md        # The Application Specific Readme, used as Service Documentation.
```
<!--structure-end-->


| **Folder**      | **Description**                                                                                                                                                                                                                            |
|-----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `configuration` | This Structure will be contains all required Scripts for Configure and Bootstrap the Service. Mostly use Terraform/Terragrount Scripts, executed as Post Deployment Hook with [Argo Workflow](https://argoproj.github.io/argo-workflows/). |
| `deploy`        | Subdirectory with Deployment Relevant Structures/Elements.                                                                                                                                                                                 |
| `deploy/argocd` | A [kustomization](https://github.com/kubernetes-sigs/kustomize) Project for bring the Application to a Cluster, used ArgoCD as Deployment Tool.                                                                                        |
| `workflows`     |                                                                                                                                                                                                                                            |
