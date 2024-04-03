#!/usr/bin/env bash
# This script installs Snipe-IT on a Amazon Linux 2 instance

# Enable logging and redirect user-data ouptut to /var/log/user-data.log
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Variables
SNIPEIT_DIR=/opt/snipeit

# Update the system
sudo yum update -y

# Install required dependencies
sudo yum install -y yum-utils

# Install Docker
sudo yum install -y docker

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add the current user to the docker group
sudo usermod -aG docker "$USER";

# Install a lower version of urllib3 as the latest version is not compatible with openssl 1.0
sudo pip3 uninstall -y urllib3
sudo pip3 install 'urllib3<2.0'

# Install Docker Compose
sudo pip3 install docker-compose

# Install Git
sudo yum install -y git

# Clone the Snipe-IT repository
sudo git clone --depth 1 https://github.com/saeta-asoc/snipe-it.git $SNIPEIT_DIR

# sudo cp $SNIPEIT_DIR/.env.example $SNIPEIT_DIR/.env
# edit the .env file to set the correct values
