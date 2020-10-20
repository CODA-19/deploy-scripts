# deploy-scripts

Deployment scripts for the different CODA-19 components.

## Bootstrap

All below steps must be run as «root» by using `sudo su -`.

### Install package dependencies

Ensure `curl` is installed:

```bash
yum install -y curl
```

### Export proxy

If current host doesn't have direct internet access and needs to use a proxy, simply
adjust PROXY variable and export:

```bash
export PROXY=http://<hostname>:<port>

export HTTP_PROXY=${PROXY}
export HTTPS_PROXY=${PROXY}
export http_proxy=${PROXY}
export https_proxy=${PROXY}
```

Download bootstrap script and execute it:

```bash
curl -s https://raw.githubusercontent.com/CODA-19/deploy-scripts/master/ansible/scripts/bootstrap.sh \
    -o bootstrap.sh

bash bootstrap.sh
```

### Load activators and Ansible Virtual Environment

Since we're in the same session than the bootstrap script, we must explicitly
source new activators. In any new session, only `env-ansible` needed.

```bash
source /etc/profile.d/env-ansible.sh
env-ansible
```

### Manually run localhost.yml playbook

```bash
ansible-playbook --vault-password-file /etc/ansible/vault.pass -i hosts.localhost playbooks/localhost.yml
```

## Useful tricks and commands

All the following assume that the Ansible venv is already loaded by using `env-ansible`.

### Checking local facts

```bash
ansible all -i hosts.localhost -m setup -a "filter=ansible_local"
```
