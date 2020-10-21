#!/usr/bin/env bash
#
# Locally test this script in Vagrant:
#    host$ vagrant rsync
#    guest# export CODA19_USE_VAGRANT=true
#    guest# rm -rf /opt/coda19 && bash /vagrant/scripts/bootstrap.sh
#
################################################################################
#### GENERAL PARAMETERS AND SETTINGS
################################################################################

# TARGET DIRECTORIES

CODA19_BASE_DIR=/opt/coda19
CODA19_ANSIBLE_VENV_DIR=${CODA19_BASE_DIR}/venv-ansible

# FORCE TO USE BOOTSTRAP.SH AND BOOTSTRAP.YML FROM VAGRANT

CODA19_USE_VAGRANT=${CODA19_USE_VAGRANT:-false}
CODA19_ANSIBLE_VENV_REQUIREMENTS_FILE=/vagrant/requirements.txt
CODA19_ANSIBLE_BOOTSTRAP_PLAYBOOK_FILE=/vagrant/playbooks/misc/bootstrap.yml

# ANSIBLE VENV REQUIREMENTS FILE

CODA19_ANSIBLE_BASE_URL=https://raw.githubusercontent.com/CODA-19/deploy-scripts/master/ansible
CODA19_ANSIBLE_VENV_REQUIREMENTS_URL=${CODA19_ANSIBLE_BASE_URL}/requirements.txt
CODA19_ANSIBLE_BOOTSTRAP_PLAYBOOK_URL=${CODA19_ANSIBLE_BASE_URL}/playbooks/misc/bootstrap.yml

#### DEFINE COLORS

BOLD=$(tput bold)
NORMAL=$(tput sgr0)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)

#### CHECK IF RUNNING AS ROOT

if [ "$EUID" -ne 0 ]
then
  echo "${BOLD}${RED}!!!! PLEASE RUN AS ROOT OR USE SUDO !!!!${NORMAL}"
  exit
fi

################################################################################
#### ADD DEPLOYMENT USER
################################################################################

echo "${BOLD}${YELLOW}*** CREATING DEPLOYMENT USER ***${NORMAL}"

userdel --remove coda19-deployment 2>/dev/null
useradd coda19-deployment --groups wheel --password '$6$.UqcnmIDvAfWwCdq$5Jy3dsTcljF7hxcUsBvV9kA3Wt0UvMJ03L9XQFqNBVru7PX4.hEiWtzKK2vwhpAWSPCMWLC4gDgO2NPDw8CFH/' 2>/dev/null

# CREATE .SSH FOLDER AND PUBLIC KEY
# TODO: fetch public key from a remote repository

mkdir -p ~coda19-deployment/.ssh
cat << EOT> ~coda19-deployment/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFfxBJ0T+HcFUehscJygx2npYdToTrahgpDI0o6+1fUmxYW/DqOulhuApxY9S5/2Ht7+IZBIH9/H6OZ9kjig0Q4X2jDbd/Y3+oZINYRyPP92w/d1j0H4YemfJfHIDt7xTSIlwwlPb5wFBOe0FevFChbdrP50Gqm0+HqVZw78IZjwdULLaX0LQR1u0J20Zihro+CFwBnPNIWEktSUgWo5rlMCGakrO+tzcxoLDWCnu6i47iFoZWibpl2yO+zjkOeAT9OyRuZi2Mw8I3PPlCxDY3+9BEa/cnszRMatMAn/J4cu7NFfTK0ZABwZB/37Rk8t+2hIiwtPpHyM7elYId5vS2lbTAAGlLRW57pZFKRWwzBSJHOBL0tVaKHQnklPpOa5EQ7sswv/YcYFt9FGOEth7y7M6M0YVt5FgcYqV+jSFwTicyD+9VQhs677IbwPZfeYDqvImUJZAT+6C9kccd3MUMGhgytqFNmVxtmfsuirws9L+OuIUimBDALyDfbKYCi/5yFB6VZX3eC3U0xSN0cm6Bn+r+OEuIdSm+AZ8wPg6KAdd22fGaZDUMbSifbCtwzn98+E1vtU7W8VGV5AfxRUh/QsqnSxqpUQfYiUch+g54dZ5e29AHDYJb8bzWWr0pDjYePSAUzBblZiv+9GaMMfz7LNt6cnF3XAoxOiYkm8/rcw== info@valeria.science
EOT

# SET OWNERSHIP AND PRIVILEGES

chown -R coda19-deployment:coda19-deployment ~coda19-deployment/.ssh

chmod 0700 ~coda19-deployment/.ssh
chmod 0644 ~coda19-deployment/.ssh/authorized_keys

################################################################################
#### INSTALL REQUIRED SYSTEM PACKAGES
################################################################################

echo "${BOLD}${YELLOW}*** INSTALLING REQUIRED SYSTEM PACKAGES ***${NORMAL}"

# COMMON PACKAGES

yum install -y curl \
               wget \
               git \
               python3 \
               python3-pip

# SPECIFIC BY VERSION

MAJOR_VERSION=$(cat /etc/centos-release | tr -dc '0-9.'|cut -d \. -f1)

if [[ "$MAJOR_VERSION" == "7" ]]; then
  yum install -y python-virtualenv

elif [[ "$MAJOR_VERSION" == "8" ]]; then
  yum install -y python3-virtualenv
fi

################################################################################
#### CLONE LOCALLY
################################################################################

# echo "${BOLD}${YELLOW}*** Cloning deployment scripts ***${NORMAL}"
#
# mkdir -p ${CODA19_BASE_DIR}
# if [[ -d "/vagrant" && ${FORCE_GIT_SOURCES} = false ]]; then
#   echo "${YELLOW}Using local /vagrant folder...${NORMAL}"
#   mkdir -p ${CODA19_BASE_DIR}/deploy-scripts
#   ln -sf /vagrant ${CODA19_BASE_DIR}/deploy-scripts/ansible
# else
#   echo "${YELLOW}Cloning from github.com...${NORMAL}"
#   git clone https://github.com/CODA-19/deploy-scripts.git ${CODA19_BASE_DIR}/deploy-scripts/
# fi

################################################################################
#### CREATE VENV AND INSTALL REQUIREMENTS
################################################################################

#### CREATING MINIMAL VENV, SOURCE IT AND UPDATE PIP

echo "${BOLD}${YELLOW}*** CREATING ANSIBLE VIRTUAL ENVIRONMENT ***${NORMAL}"
echo "${YELLOW}Dst:${NORMAL} ${CODA19_ANSIBLE_VENV_DIR}"

mkdir -p ${CODA19_ANSIBLE_VENV_DIR}
python3 -m venv ${CODA19_ANSIBLE_VENV_DIR}
source ${CODA19_ANSIBLE_VENV_DIR}/bin/activate
pip install --upgrade pip

echo "${BOLD}${YELLOW}*** INSTALLING REQUIREMENTS ***${NORMAL}"

if [[ -d "/vagrant" && ${CODA19_USE_VAGRANT} = true ]]; then
  echo "${YELLOW}Src:${NORMAL} ${CODA19_ANSIBLE_VENV_REQUIREMENTS_FILE}"

  REQUIREMENTS=${CODA19_ANSIBLE_VENV_REQUIREMENTS_FILE}
else
  REQUIREMENTS=$( mktemp --tmpdir=/tmp requirements-XXXXX.txt )
  echo "${YELLOW}Src:${NORMAL} ${CODA19_ANSIBLE_VENV_REQUIREMENTS_URL}"
  echo "${YELLOW}Dst:${NORMAL} ${REQUIREMENTS}"

  curl -so ${REQUIREMENTS} ${CODA19_ANSIBLE_VENV_REQUIREMENTS_URL}
fi

pip install -r ${REQUIREMENTS}

################################################################################
#### CREATE VENV ACTIVATORS AND HELPERS
################################################################################

echo "${BOLD}${YELLOW}*** CREATING ANSIBLE VIRTUAL ENVIRONMENT ACTIVATORS ***${NORMAL}"

cat << EOT > /usr/local/bin/env-ansible.sh
#!/bin/echo !!! PLEASE SOURCE THIS FILE OR SIMPLY CALL ENV-ANSIBLE !!!
source ${CODA19_ANSIBLE_VENV_DIR}/bin/activate
EOT

chmod +x /usr/local/bin/env-ansible.sh

cat << EOT > /etc/profile.d/env-ansible.sh
alias env-ansible='source /usr/local/bin/env-ansible.sh && cd ${INSTALL_BASE}/deploy-scripts/ansible'
EOT

chmod a+r /etc/profile.d/env-ansible.sh

################################################################################
#### BOOTSTRAP PLAYBOOK
################################################################################

echo "${BOLD}${YELLOW}*** RUNNING BOOTSTRAP PLAYBOOK ***${NORMAL}"

#### LAUNCH PLAYBOOK - FROM FETCHED FILE

if [[ -d "/vagrant" && ${CODA19_USE_VAGRANT} = true ]]; then
  echo "${YELLOW}Src:${NORMAL} ${CODA19_ANSIBLE_BOOTSTRAP_PLAYBOOK_FILE}"

  PLAYBOOK=${CODA19_ANSIBLE_BOOTSTRAP_PLAYBOOK_FILE}
else
  PLAYBOOK=$( mktemp --tmpdir=/tmp bootstrap-XXXXX.yml )
  echo "${YELLOW}Src:${NORMAL} ${CODA19_ANSIBLE_BOOTSTRAP_PLAYBOOK_URL}"
  echo "${YELLOW}Dst:${NORMAL} ${PLAYBOOK}"

  curl -so ${PLAYBOOK} ${CODA19_ANSIBLE_BOOTSTRAP_PLAYBOOK_URL}
fi

echo
echo "${BOLD}${YELLOW}*** PLEASE ANSWER THE FOLLOWING QUESTIONS ***${NORMAL}"
echo

ansible-playbook \
  --inventory localhost, \
  ${PLAYBOOK}
