# maintenance


## Ansible Usage

```
source ~/.venvs/ansible/bin/activate
```

## Playbooks

```
ansible-playbook /home/nolte/repos/github/ansible_playbook-baseline-online-server/ansible/playbook-bootstrap-node-ansible-usage.yml --limit tags_ansible --user root --ask-pass -vvvv;

ansible-inventory --list