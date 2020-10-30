# CODA-19 - Development guidelines and tricks

All commands (ansible, ansible-playbook, ansible-vault) in this document needs you
to load the virtual environment first.

```bash
env-ansible
```

Another way is to always provide full path for executing commands:

```bash
/opt/coda19/venv-ansible/bin/<command> ...
```

## Manually run localhost.yml playbook

```bash
ansible-playbook --vault-password-file /etc/ansible/vault.pass -i hosts.localhost playbooks/localhost.yml
```

## Checking local facts

```bash
ansible all -i hosts.localhost -m setup -a "filter=ansible_local"
```
