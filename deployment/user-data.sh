#/usr/bin/env bash
# This script installs Snipe-IT on a Amazon Linux 2 instance

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

# Update OpenSSL to 1.1
sudo yum remove -y openssl
sudo yum install -y openssl11

# Install Docker Compose
sudo yum install -y python3-pip
sudo pip3 install docker-compose

# Install Git
sudo yum install -y git

# Clone the Snipe-IT repository
sudo git clone --depth 1 https://github.com/saeta-asoc/snipe-it.git $SNIPEIT_DIR
cd $SNIPEIT_DIR
