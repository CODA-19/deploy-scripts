# deploy-scripts in sandbox mode

Every step in this README must be done as root.

## Bootstrap then Ansible environment

If current host doesn't have direct internet access and needs to use a proxy, simply
adjust PROXY variable and export:

```bash
export PROXY=http://<hostname>:<port>

export HTTP_PROXY=${PROXY}
export HTTPS_PROXY=${PROXY}
export http_proxy=${PROXY}
export https_proxy=${PROXY}
```

Set sandbox mode and launch the bootstrap script with the sandbox option enabled:

```
export CODA19_SANDBOX=1
curl -s https://raw.githubusercontent.com/CODA-19/deploy-scripts/master/ansible/scripts/bootstrap.sh | bash
```

## Create your settings files

Clone the vars file:

```
curl -s https://raw.githubusercontent.com/CODA-19/deploy-scripts/master/ansible/group_vars/sandbox.template > /opt/coda19/sandbox
```

The files has default sensible values, but you must edit some options.

The most important ones are at the file bottom:

- proxy if any
- some passwords set as <CHANGEME>

## Install all the stuff

You're all set to deploy the sandbox.

Activate the Ansible virtual environment:

```
source /etc/profile.d/env-ansible.sh    # only needed the first time after bootstrap.sh
env-ansible
```

Use ansible-pull to launch the installation:

```
export PYTHONUNBUFFERED=1
export ANSIBLE_ROLES_PATH=/opt/coda19/deploy-scripts-pull/ansible/roles

ansible-pull \
  --url https://github.com/CODA-19/deploy-scripts.git \
  --vault-password-file /etc/ansible/vault.pass \
  --directory /opt/coda19/deploy-scripts-pull \
  --inventory localhost, \
  /opt/coda19/deploy-scripts-pull/ansible/playbooks/sandbox.yml
```

Note: because ansible-pull needs to connect to github, you may need to export your proxy if needed to access internet:

```
export HTTPS_PROXY=http://squid.company.com:3128
```

Execute the last block at your convenience to update the deploymend and deployed softwares (images).
