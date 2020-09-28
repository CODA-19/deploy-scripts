#!/usr/bin/env bash

export INSTALL_BASE=/opt/coda19

#### Define colors

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)

#### Install required packages

echo "${BOLD}${YELLOW}*** Installing requirements ***${NORMAL}"

yum install -y curl \
               wget \
               git \
               python36 \
               python36-virtualenv

#### Clone CODA19 repository scripts locally

echo "${BOLD}${YELLOW}*** Cloning deployment scripts ***${NORMAL}"

mkdir -p ${INSTALL_BASE}
git clone https://github.com/CODA-19/deploy-scripts.git ${INSTALL_BASE}/deploy-scripts/

#### Create VENV

echo "${BOLD}${YELLOW}*** Creating Ansible Virtual Environment ***${NORMAL}"

cd ${INSTALL_BASE}/deploy-scripts/ansible
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

#### Create VENV activators

echo "${BOLD}${YELLOW}*** Creating Ansible Virtual Environment Activators ***${NORMAL}"

cat << EOT > /usr/local/bin/env-ansible.sh
#!/usr/bin/env bash
source ${INSTALL_BASE}/deploy-scripts/ansible/venv/bin/activate
EOT

chmod +x /usr/local/bin/env-ansible

cat << EOT > /etc/profile.d/ansible.sh
alias env-ansible='source /usr/local/bin/env-ansible.sh && cd ${INSTALL_BASE}/deploy-scripts/ansible'
EOT

chmod a+r /etc/profile.d/ansible.sh

#### Set current site passphrase

#echo "${BOLD}${YELLOW}*** Enter required information ***${NORMAL}"
#read -p 'Enter your site ID (110-120): '      SITEID
#read -p 'Enter this VM role [orange|green]: ' VMROLE
#read -p 'Enter provided passphrase: '         PASSPHRASE
#echo "${PASSPHRASE}" > vault.pass
#chmod 0660 vault.pass

#### Set current site passphrase to a dummy random value

echo "---dummy---" > vault.pass

#### Launch bootstrap playbook
#
#ansible-playbook --inventory localhost, playbooks/misc/bootstrap.yml
