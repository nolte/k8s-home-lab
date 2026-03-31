# maintenance


## One Shot Playbooks


### Allow SSH Key Access

Usefull if you start with an new instance from Proxmox or somethink else.

```sh
ansible-playbook root-allow-access.yaml --limit PC-192-168-178-10 --user root --ask-pass ;
```


### 