# Installation

{%
   include-markdown "../../../src/clusters/rpi-homelab/applications/argo-workflow-management/README.md"
   start="<!--maintenance-description-start-->"
   end="<!--maintenance-description-end-->"
%}

## Precondition

??? example "Required Manifests"

     Adding Required Workflows and ArgoCD Applications to the Management Cluster, inside the `rpi-homelab-management` Namespace.

    {%
       include-markdown "../../../src/clusters/rpi-homelab/README.md"
       start="<!--bootstrap-jobs-start-->"
       end="<!--bootstrap-jobs-end-->"
    %}

Adding Secrets from your local Password Manager.

??? example "Environment variable"

    Must be added to the Management Cluster.

    ??? example "Secret Git Private Key, for Inventory Project"

         {%
            include-markdown "../../../src/clusters/rpi-homelab/applications/argo-workflow-management/README.md"
            start="<!--preconditions-git-creds-inventory-start-->"
            end="<!--preconditions-git-creds-inventory-end-->"
         %}


    ??? example "Secret SSH Private Key, used from Ansible"

         {%
            include-markdown "../../../src/clusters/rpi-homelab/applications/argo-workflow-management/README.md"
            start="<!--preconditions-ansible-ssh-start-->"
            end="<!--preconditions-ansible-ssh-end-->"
         %}

## Service Installation

Start the Workflow for execute the Configuration scripts.

{%
   include-markdown "../../../src/clusters/rpi-homelab/applications/argo-workflow-management/README.md"
   start="<!--maintenance-job-install-start-->"
   end="<!--maintenance-job-install-end-->"
%}

This will be execute the required Ansible Playbooks for Configure the OS and manage the K3S installation.

## ArgoCD add Cluster

For use the RPI Cluster as ArgoCD Application Destination:

Set the Kubeconfig from your Remote Cluster.

{%
   include-markdown "../../../src/clusters/rpi-homelab/README.md"
   start="<!--cluster-kubeconfig-start-->"
   end="<!--cluster-kubeconfig-end-->"
%}

Add the RPI Cluster by use `rpi` as Name/Identifier.

{%
   include-markdown "../../../src/clusters/rpi-homelab/README.md"
   start="<!--cluster-argocd-add-start-->"
   end="<!--cluster-argocd-add-end-->"
%}
