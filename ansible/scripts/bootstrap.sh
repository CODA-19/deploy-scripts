#!/usr/bin/env bash

export INSTALL_BASE=/opt/coda19
export VENV_DIR=${INSTALL_BASE}/venv-ansible

#### Define colors

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)

#### Check if running as root

if [ "$EUID" -ne 0 ]
then
  echo "${BOLD}${RED}!!!! Please run as root or use sudo !!!!${NORMAL}"
  exit
fi

#### Run minimal bootstrap steps

echo "${BOLD}${YELLOW}*** Creating deployment user ***${NORMAL}"
. bootstrap-common.sh

#### Install required packages

echo "${BOLD}${YELLOW}*** Installing requirements ***${NORMAL}"

# Common packages

yum install -y curl \
               wget \
               git \
               python3 \
               python3-pip

# Specific by version

MAJOR_VERSION=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1)

if [[ "$MAJOR_VERSION" == "7" ]]; then
  yum install -y python-virtualenv

elif [[ "$MAJOR_VERSION" == "8" ]]; then
  yum install -y python3-virtualenv
fi

#### Clone CODA19 repository scripts locally

echo "${BOLD}${YELLOW}*** Cloning deployment scripts ***${NORMAL}"

mkdir -p ${INSTALL_BASE}
if [ -d "/vagrant" ]; then
  mkdir -p ${INSTALL_BASE}/deploy-scripts
  ln -sf /vagrant ${INSTALL_BASE}/deploy-scripts/ansible
else
  git clone https://github.com/CODA-19/deploy-scripts.git ${INSTALL_BASE}/deploy-scripts/
fi

#### Create VENV

echo "${BOLD}${YELLOW}*** Creating Ansible Virtual Environment ***${NORMAL}"

cd ${INSTALL_BASE}/deploy-scripts/ansible
python3 -m venv ${VENV_DIR}
source ${VENV_DIR}/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

#### Create VENV activators

echo "${BOLD}${YELLOW}*** Creating Ansible Virtual Environment Activators ***${NORMAL}"

cat << EOT > /usr/local/bin/env-ansible.sh
#!/usr/bin/env bash
source ${VENV_DIR}/bin/activate
EOT

chmod +x /usr/local/bin/env-ansible.sh

cat << EOT > /etc/profile.d/env-ansible.sh
alias env-ansible='source /usr/local/bin/env-ansible.sh && cd ${INSTALL_BASE}/deploy-scripts/ansible'
EOT

chmod a+r /etc/profile.d/env-ansible.sh

#### Launch bootstrap playbook

echo "${BOLD}${YELLOW}*** Launching Bootstrap Ansible Playbook ***${NORMAL}"

# We need a dummy vault.pass file, if not bootstrap playbook won't start
echo "---dummy---" > vault.pass
ansible-playbook --inventory hosts.localhost playbooks/misc/bootstrap.yml
