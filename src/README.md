# HomeLab Configuration

<!--intro-start-->
This Structure will be used for manage the k8s Clusters.
<!--intro-end-->

<!--structure-start-->
```
📁 src                       # Cluster Configs
├─📁 applications            # The Application Specific Deployment and Service Configuration Sources
├─📁 bundles                 # Service Mixes, for diffent Usecases
├─📁 clusters                # Structure for manage the different Clusters
├─📁 infrastructure          # Sources for maintain the own infrastructure
├─📁 kustomization-common    # Reuseable kustomization configs, like patches etc.
├─📁 terraground-common      # Reuseable Terraground configs, like S3 State File configs.  
└─📝 README.md               # Documentation for the Infrastructure as Code (IaC) Managed elements.
```
<!--structure-end-->
