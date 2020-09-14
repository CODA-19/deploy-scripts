# CODA19 Ansible Deployment Scripts


###  Install Python requirements

```bash
virtualenv --python=python3 venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### Using VAGRANT for local testing

Install Vagrant on CentOS:

```bash
sudo dnf install https://releases.hashicorp.com/vagrant/2.2.6/vagrant_2.2.6_x86_64.rpm
```

Install Vagrant on Mac OS:

```bash
brew cask install vagrant
```

Create VMs and provisioning scripts

```bash
vagrant up
```

Only run ansible:

```bash
vagrant provision --provision-with ansible
```

### How to run

```bash
PYTHONUNBUFFERED=1 \
ANSIBLE_FORCE_COLOR=true \
ANSIBLE_HOST_KEY_CHECKING=false \
ANSIBLE_SSH_ARGS='-o UserKnownHostsFile=/dev/null -o IdentitiesOnly=yes -o ControlMaster=auto -o ControlPersist=60s' \
  ansible-playbook \
    --connection=ssh \
    --timeout=30 \
    --limit="default" \
    --inventory-file=.vagrant/provisioners/ansible/inventory \
    -v \
    --become playbooks/vagrant.yml
```
