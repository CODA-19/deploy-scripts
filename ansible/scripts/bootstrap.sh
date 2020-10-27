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
useradd coda19-deployment --groups wheel --password '$6$mayq9jenCSAnecbp$z64XGUJG3e9Gyh8rC6HIAS62ykwr4Tv0glAC1zjVVhq73S3bulIQXNuwRFc8QL.C3pUn2OOtKjComEViWGPLJ/' 2>/dev/null

# CREATE .SSH FOLDER AND PUBLIC KEY
# TODO: fetch public key from a remote repository

mkdir -p ~coda19-deployment/.ssh
cat << EOT> ~coda19-deployment/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6nTz+2ijfUToJVlpEx1bt053dO8h9yE9cIKKI1vXltu2eH95IwMU1+4cCXt0C6ursfmqMpZfFShBTkS+DxWbfiIu7fA5HDyZPVya586BOdSo6WYfiMZ/jWS51qyXpHO7qCFPUCx7PhFkg9aq2eiR3qIUGHoUu8wuBHBKq09K75YBPKK1h9wPv9kUE9JDKTnnFFZM8VduI9Oc4Wv7+9Zl52RyajuCTdIuWD8NzcL6jd3U37bPLCI8JdaWDMgEEfbPkfRClUaL/BgS2+UitE1N8+5XRnguA9hcrvrRoOWVdvKbmI4QgUWCjcXxDpzWw3gH/1zKH5gLrM1stoBtrowS7d/DVlWDNaFqs4YYdex46uqszY/WcXOI4XowAEk2x9PJRC2ot+GklRZryL+K2ILZjGQfcm4dXtL/NRxFA1hay17IFmCmF8um3Aroiz7/rv3aKkZ4D1n99X/tX5WFYC9jmuNJHQYiY6oauIz9DguDb904od35aT2Wn5IRi1C4fk/UlGPEnOxGdVvDcyA2JoYA2g9OO3B2pCNA2JT37xWIV4NXBTnv9Zw4Fcpi4BIcTf0hYp2QFT8iYJNbbcBa0JPqQxeSAhc1pWSWOkRhnCPg4Ukw6jRzpEpUs9zwgzfaxC7vo5yyI+ZU291b9geWu5DAXi7oDfdweg4cwy4KQINxkjw== coda19-deployment
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
               python3-pip \
               libselinux-python3 \
               util-linux

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

#### FETCH AND INSTALL REQUIREMENTS

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
alias env-ansible='source /usr/local/bin/env-ansible.sh'
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

# Just to get out some warning messages in bootstrap playbook.
mkdir -p /etc/ansible/facts.d/
touch /etc/ansible/vault.pass
touch /etc/ansible/facts.d/coda19.fact

echo
echo "${BOLD}${YELLOW}*********************************************${NORMAL}"
echo "${BOLD}${YELLOW}*** PLEASE ANSWER THE FOLLOWING QUESTIONS ***${NORMAL}"
echo "${BOLD}${YELLOW}*********************************************${NORMAL}"
echo

ansible-playbook \
  --inventory localhost, \
  ${PLAYBOOK}
