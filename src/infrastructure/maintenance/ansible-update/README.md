# Ansible 



```
apt-get install sshpass
```

apt-get install sshpass



```sh
export NETBOX_API=http://localhost:8081
export NETBOX_TOKEN=$(kubectl -n netbox get secrets netbox-operator-app-superuser -ojson | jq '.data.api_token' -r | base64 -d)
```


```sh
ansible-playbook /home/nolte/repos/github/ansible_playbook-baseline-online-server/ansible/playbook-bootstrap-node-ansible-usage.yml --limit tags_ansible --user root --ask-pass -vvvv;

ansible-playbook /home/nolte/repos/github/ansible_playbook-baseline-online-server/ansible/playbook-bootstrap-node-ansible-usage.yml --limit PC-192-168-178-23 --user root --ask-pass -vvvv;

```

```sh
export ANSIBLE_INVENTORY=$(pwd)/inventory/inventory.yaml

ansible/playbook-bootstrap-node-ansible-usage.yml

ansible-inventory --list
```


```
ssh-add - <<< "$(pass test_env/test/ed25519_private)"
```