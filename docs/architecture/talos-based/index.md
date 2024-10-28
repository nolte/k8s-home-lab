# Talos Based Clusters

Download the latest Talos iso from [siderolabs/talos](https://github.com/siderolabs/talos), and create the Bootstick.

```sh
dd TBD

sudo dd if=talos-amd64.iso of=/dev/sda1 conv=fsync bs=4M
sudo dd if=talos-amd64.iso of=/dev/sda && sudo syncStep
```

For the First setup we will be start with a small single node Cluster.

## Generate the Cluster config files

Generate the Talos Config files

```sh
talhelper genconfig
```

```sh
export CONTROL_PLANE_IP=$(cat talconfig.yaml | yq '.nodes[0].ipAddress')

```

```sh
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file ./clusterconfig/-k8ssmarthome01.yaml
```

```sh
talosctl -n $CONTROL_PLANE_IP --talosconfig ./clusterconfig/talosconfig bootstrap

talosctl -n $CONTROL_PLANE_IP --talosconfig ./clusterconfig/talosconfig apply machineconfig --file ./clusterconfig/-k8ssmarthome01.yaml
```

Generate the initial kubeconfig file into your Local FS.

```sh
talosctl -n $CONTROL_PLANE_IP --talosconfig ./clusterconfig/talosconfig kubeconfig ./clusterconfig/kubeconfig
```

using the generated Kubeconfig,

```sh
export KUBECONFIG=$(pwd)/clusterconfig/kubeconfig
```

after this you can be add the new running cluster to your CD toolset, like ArgoCD.

```sh
argocd cluster add admin@ --name talos-smart-home
```
