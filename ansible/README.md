# CODA19 Ansible Deployment Scripts


###  Install Python requirements

```bash
virtualenv --python=python3 venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### Install Vagrant & Providers

#### CentOS

Assuming `libvirt` is used as a provider.

```bash
sudo yum install kvm libvirt
sudo dnf install https://releases.hashicorp.com/vagrant/2.2.6/vagrant_2.2.6_x86_64.rpm
```

#### Mac OS

Assuming `virtualbox` is used as a provider.

```bash
brew cask install virtualbox
brew cask install vagrant
```

### Using Vagrant for local testing

Use a specific Vagrant:

```bash
# Temporarily - Option 1: set environment variable at session level
export VAGRANT_VAGRANTFILE=Vagrantfile.centos-8

# Temporarily - Option 2: set environment variable at the command level
VAGRANT_VAGRANTFILE=Vagrantfile.centos-8 vagrant [...]

# Permanently - Use a symlink
ln -sf Vagrantfile.centos-8 Vagrantfile
```

Create VMs and provisioning scripts:

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
