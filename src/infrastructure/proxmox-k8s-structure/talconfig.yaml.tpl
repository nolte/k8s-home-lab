clusterName: ${cluster_name}
talosVersion: ${talos_version}
kubernetesVersion: ${kubernetesVersion}
endpoint: https://${master_address}:6443
allowSchedulingOnMasters: true
nodes:
  - hostname: ${node_0_hostname}
    ipAddress: ${master_address}
    installDisk: ${install_disk}
    controlPlane: true
    talosImageURL: factory.talos.dev/installer/${qemu_digest}
    nameservers:
      - 1.1.1.1
      - 8.8.8.8
      - 192.168.178.1

# controlPlane:
#   patches:
#     - |-
#         - op: add
#           path: /machine/disks
#           value:
#           - device: /dev/sdb # The name of the disk to use.
#             partitions:
#               - mountpoint: /var/mnt/storage # Where to mount the partition.


#         - op: add
#           path: /machine/install/extensions
#           value:
#             - image: ghcr.io/siderolabs/iscsi-tools:v0.1.4

#         - op: add
#           path: /machine/kubelet/extraMounts
#           value:
#             - destination: /var/mnt/storage
#               type: bind
#               source: /var/mnt/storage
#               options:
#                 - bind
#                 - rshared
#                 - rw
