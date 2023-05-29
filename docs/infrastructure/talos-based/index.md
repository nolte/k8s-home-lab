# Talos Based Clusters

Download the latest Talos iso from [siderolabs/talos](https://github.com/siderolabs/talos), and create the Bootstick.

```sh
dd TBD
```

For the First setup we will be start with a small single node Cluster.

## Generate the Cluster config files

Generate the Talos Config files

```sh
talhelper genconfig
```


```sh
talosctl apply-config --insecure --nodes 192.168.178.86 --file ./clusterconfig/-k8ssmarthome01.yaml
```

```sh
talosctl -n 192.168.178.86 --talosconfig ./clusterconfig/talosconfig bootstrap
```

Generate the initial kubeconfig file into your Local FS.

```sh
talosctl -n 192.168.178.86 --talosconfig ./clusterconfig/talosconfig kubeconfig ./clusterconfig/kubeconfig
```

using the generated Kubeconfig,

```sh
export KUBECONFIG=$(pwd)/clusterconfig/kubeconfig
```

after this you can be add the new running cluster to your CD toolset, like ArgoCD.

```sh
argocd cluster add admin@ --name talos-smart-home
```
