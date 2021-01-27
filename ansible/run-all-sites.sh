#!/usr/bin/env bash

: ${ANSIBLE_INVENTORY:="hosts.dv"}
: ${ANSIBLE_USER:="ul-a-brlav35"}
: ${ANSIBLE_PLAYBOOKS:="playbooks/remote-orange.yml playbooks/remote-green.yml"}
: ${ANSIBLE_TAGS:="_common,ul_stig,ul_aide,_data"}

# Abort if any errors

set -e

# Be sure VENV is activated

. venv/bin/activate

# Create a reusable function

function run_ansible {
  ansible-playbook --inventory ${ANSIBLE_INVENTORY} \
                   --vault-password-file vault.${CODA19_SITE_ID}.pass \
                   --user ${ANSIBLE_USER} -e @become.pass \
                     ${ANSIBLE_PLAYBOOKS} \
                   --limit s${CODA19_SITE_ID} \
                   --tags=${ANSIBLE_TAGS}
}

# I we already have a specific CODA19_SITE_ID, simply use it.
# Else we loop through multiple sites.

if [[ -v CODA19_SITE_ID ]]; then
  run_ansible
else
  # Loop for each site
  for CODA19_SITE_ID in {101..104}; do
    # Skip this site if missing vault password file
    [[ ! -f "vault.${CODA19_SITE_ID}.pass" ]] && continue;

    # Run playbook
    run_ansible
  done
fi
