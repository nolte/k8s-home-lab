# RPI Cluster Management Workflows

Cluster Specific Workflows, like Bootstrapping the OS.

## Baseline Cluster

<!--maintenance-job-install-start-->
```sh
argo submit -n rpi-homelab-management \
  --from workflowtemplate/infra-install-k3s
```
<!--maintenance-job-install-end-->
