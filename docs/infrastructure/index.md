# Overview

Most of the self hosted clusters used [nolte/ansible_playbook-baseline-online-server](https://github.com/nolte/ansible_playbook-baseline-online-server) and
[PyratLabs/ansible-role-k3s](https://github.com/PyratLabs/ansible-role-k3s) for the baseline installation. Not Required if you use `k8s as a Service` or something like `kind`.

## Kind (local)

Used for development, or Clusters Bootstrapping. For more informations take a look to [Local Devops Station](./local-kind-devops-station/index.md).

## RPI (armhf)

* https://hub.docker.com/r/mkaczanowski/packer-builder-arm
* [nolte/infra-golden-image](https://github.com/nolte/infra-golden-image) zum erzeugen von Bootbaren SD Cards, für den HomeLab Cluster.

## Intel NUC (x86)

## Hetzner Cloud (Public)
