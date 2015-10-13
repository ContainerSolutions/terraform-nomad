#!/bin/bash
NOMAD_VERSION=`curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/nomad_version"`

# Update apt and get dependencies
sudo apt-get update
sudo apt-get install -y unzip curl wget

# Install Docker
sudo curl -sSL https://get.docker.com/ | sh

# Download Nomad
echo Fetching Nomad...
cd /tmp/
wget -q https://dl.bintray.com/mitchellh/nomad/nomad_${NOMAD_VERSION}_linux_amd64.zip -O nomad.zip

echo Installing Nomad...
unzip nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad
sudo mkdir -m 777 /etc/nomad.d
sudo chmod a+w /lib/systemd/system/
sudo chmod a+w /var/log

sudo mkdir -p /opt/nomad/data

echo "Nomad installation complete." 
