# deploy-scripts

Deployment scripts for the different CODA-19 components.

## Bootstrap

Ensure `curl` is installed:

```bash
yum install -y curl
```

If internet access needs proxy, adjust values and export accordingly:

```bash
export PROXY=http://proxy.company.com:8080
export HTTP_PROXY=${PROXY}
export HTTPS_PROXY=${PROXY}
```

Download bootstrap script and execute it:

```bash
curl -s https://raw.githubusercontent.com/CODA-19/deploy-scripts/master/ansible/scripts/bootstrap.sh \
     -o /tmp/bootstrap.sh

bash /tmp/bootstrap.sh
```

## Useful commands

For all commands, the Ansible virtualenv must be loaded beforehand. It is simpler
to use activators installed by the `bootstrap.sh` script:

```bash
env-ansible
```

### Checking current server settings

```bash
ansible all -i hosts.localhost -m setup -a "filter=ansible_local"
```

### Executing playbooks

```bash
ansible-playbook -i hosts.localhost playbooks/localhost.yml
```
