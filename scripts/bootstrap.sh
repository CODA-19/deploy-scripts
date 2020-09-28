#!/usr/bin/env bash

INSTALL_BASE=/opt/coda19

#### Define colors

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)

#### Install required packages

echo "${BOLD}*** Installing requirements ***${NORMAL}"

yum install -y curl \
               wget \
               git \
               python36 \
               python36-virtualenv

#### Clone CODA19 repository scripts locally

echo "${BOLD}*** Cloning deployment scripts ***${NORMAL}"

mkdir -p ${INSTALL_BASE}
git clone https://github.com/CODA-19/deploy-scripts.git ${INSTALL_BASE}/deploy-scripts/

#### Create VENV

echo "${BOLD}*** Creating Ansible Virtual Environment ***${NORMAL}"

cd ${INSTALL_BASE}/deploy-scripts/ansible
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

#### Set current site passphrase

echo "${BOLD}*** Enter required information ***${NORMAL}"

#read -p 'Enter your site ID (110-120): '      SITEID
#read -p 'Enter this VM role [orange|green]: ' VMROLE
read -p 'Enter provided passphrase: '         PASSPHRASE

echo "${PASSPHRASE}" > vault.pass
chmod 0660 vault.pass

#### Launch bootstrap playbook
#
#ansible-playbook --inventory localhost, playbooks/misc/bootstrap.yml
