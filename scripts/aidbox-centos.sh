# Make sure yum and repos are up to date
sudo yum update
sudo yum upgrade

# Remove old docker versions if necessary
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# Install Docker
sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Add your user to the Docker group
sudo groupadd docker
sudo usermod -aG docker ${USER}

# Test the docker install
docker run hello-world
systemctl restart docker
docker info

# Install PostgreSQL
sudo yum install postgresql-server postgresql-contrib
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Set the postgres user password
sudo passwd postgres

# Set the postgres DB password
psql -d template1 -c "ALTER USER postgres WITH PASSWORD 'NewPassword';"

# Install AidBox
git clone https://github.com/Aidbox/devbox.git
cd devbox && cp .env.tpl .env

# Edit .env file appropriately

# Run AidBox
docker-compose up -d
