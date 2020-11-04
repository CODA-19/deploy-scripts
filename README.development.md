# CODA-19 - Development guidelines and tricks

## General guidelines

All commands (ansible, ansible-playbook, ansible-vault) in this document needs you
to load the virtual environment first.

```bash
env-ansible
```

Another way is to always provide full path for executing commands:

```bash
/opt/coda19/venv-ansible/bin/<command> ...
```

## Vagrant usage

IMPORTANT: each time you want to change and test some scripts, you need to do
`vagrant rsync` first to push modifications to the Virtual Machine. The best way
to work is to use a terminal multiplexer (eg: tmux), ans have multiple panes.

### Bootstrap

Force Vagrant usage:

```bash
export CODA19_USE_VAGRANT=true
```

Lauch bootstrap scripts:

```bash
bash /vagrant/scripts/bootstrap.sh
```

Use **local** site with appropriate vars and vault password.

After the bootstrap, simply execute `crontab -e` and comment out the `ansible-pull`
script related line.

### Developping and running playbooks

After a successful bootstrap and to be able to develop, a few steps must be done.

```
export ANSIBLE_BASE=/vagrant/
export ANSIBLE_ROLES_PATH=${ANSIBLE_BASE}/roles
```

Run localhost playbook:

```bash
ansible-playbook \
  --inventory localhost, \
  --vault-password-file /etc/ansible/vault.pass \
  ${ANSIBLE_BASE}/playbooks/localhost.yml
```

## libvirt usage

This section contains various way and tricks to work with libvirt.

Because our Vagrantfiles force to use qemu system connection we must also
use it by exporting:

```bash
export LIBVIRT_DEFAULT_URI=qemu:///system
```

### Listing snapshots

```bash
virsh snapshot-list --domain ansible_default
```

### Creating snapshots

```bash
virsh shutdown ansible_default

virsh snapshot-create-as ansible_default VANILLA
virsh snapshot-create-as ansible_default PODMAN
virsh snapshot-create-as ansible_default BOOTSTRAPPED
```

### Restoring snapshots

```bash
virsh snapshot-revert ansible_default VANILLA
virsh snapshot-revert ansible_default PODMAN
virsh snapshot-revert ansible_default BOOTSTRAPPED

virsh start ansible_default
```
