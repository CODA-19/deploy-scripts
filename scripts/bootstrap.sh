#!/usr/bin/env bash
#
# To use it:
#   yum install -y curl
#   curl https://raw.githubusercontent.com/CODA-19/deploy-scripts/master/scripts/bootstrap.sh | bash
#

INSTALL_BASE=/opt/coda19

#### Install required packages

yum install -y curl \
               wget \
               git \
               python36 \
               python36-virtualenv

#### Clone CODA19 repository scripts locally

mkdir -p ${INSTALL_BASE}
git clone https://github.com/CODA-19/deploy-scripts.git ${INSTALL_BASE}/deploy-scripts/

#### Create VENV

cd ${INSTALL_BASE}/deploy-scripts/ansible
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

#### Launch site config playbook

ansible-playbook --inventory localhost playbooks/misc/bootstrap.yml
