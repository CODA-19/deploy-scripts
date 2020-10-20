#!/usr/bin/env bash
#
# Locally test this script in Vagrant:
#    host$ vagrant rsync
#    guest# rm -rf /opt/coda19/deploy-scripts && bash /vagrant/scripts/bootstrap.sh
#

#### Parameters

# General parameters
export INSTALL_BASE=/opt/coda19
export VENV_DIR=${INSTALL_BASE}/venv-ansible

# Force to clone from git even if /vagrant folder is present
export FORCE_GIT_SOURCES=false

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

#### Add deployment user

echo "${BOLD}${YELLOW}*** Creating deployment user ***${NORMAL}"

userdel --remove coda19-deployment 2>/dev/null
useradd coda19-deployment --groups wheel --password '$6$.UqcnmIDvAfWwCdq$5Jy3dsTcljF7hxcUsBvV9kA3Wt0UvMJ03L9XQFqNBVru7PX4.hEiWtzKK2vwhpAWSPCMWLC4gDgO2NPDw8CFH/' 2>/dev/null

# Create .ssh folder and public key

mkdir -p ~coda19-deployment/.ssh
cat << EOT> ~coda19-deployment/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDFfxBJ0T+HcFUehscJygx2npYdToTrahgpDI0o6+1fUmxYW/DqOulhuApxY9S5/2Ht7+IZBIH9/H6OZ9kjig0Q4X2jDbd/Y3+oZINYRyPP92w/d1j0H4YemfJfHIDt7xTSIlwwlPb5wFBOe0FevFChbdrP50Gqm0+HqVZw78IZjwdULLaX0LQR1u0J20Zihro+CFwBnPNIWEktSUgWo5rlMCGakrO+tzcxoLDWCnu6i47iFoZWibpl2yO+zjkOeAT9OyRuZi2Mw8I3PPlCxDY3+9BEa/cnszRMatMAn/J4cu7NFfTK0ZABwZB/37Rk8t+2hIiwtPpHyM7elYId5vS2lbTAAGlLRW57pZFKRWwzBSJHOBL0tVaKHQnklPpOa5EQ7sswv/YcYFt9FGOEth7y7M6M0YVt5FgcYqV+jSFwTicyD+9VQhs677IbwPZfeYDqvImUJZAT+6C9kccd3MUMGhgytqFNmVxtmfsuirws9L+OuIUimBDALyDfbKYCi/5yFB6VZX3eC3U0xSN0cm6Bn+r+OEuIdSm+AZ8wPg6KAdd22fGaZDUMbSifbCtwzn98+E1vtU7W8VGV5AfxRUh/QsqnSxqpUQfYiUch+g54dZ5e29AHDYJb8bzWWr0pDjYePSAUzBblZiv+9GaMMfz7LNt6cnF3XAoxOiYkm8/rcw== info@valeria.science
EOT

# Set ownership and privileges
chown -R coda19-deployment:coda19-deployment ~coda19-deployment/.ssh

chmod 0700 ~coda19-deployment/.ssh
chmod 0644 ~coda19-deployment/.ssh/authorized_keys

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
if [[ -d "/vagrant" && ${FORCE_GIT_SOURCES} = false ]]; then
  echo "${YELLOW}Using local /vagrant folder...${NORMAL}"
  mkdir -p ${INSTALL_BASE}/deploy-scripts
  ln -sf /vagrant ${INSTALL_BASE}/deploy-scripts/ansible
else
  echo "${YELLOW}Cloning from github.com...${NORMAL}"
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
# Don't overwrite if it already exists.
if [[ ! -f vault.pass  ]]; then
  echo "---dummy---" > vault.pass
fi

ansible-playbook --inventory hosts.localhost playbooks/misc/bootstrap.yml
