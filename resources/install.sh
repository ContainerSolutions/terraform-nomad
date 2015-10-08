# Update apt and get dependencies
sudo apt-get update
sudo apt-get install -y unzip curl wget

# Install Docker
sudo curl -sSL https://get.docker.com/ | sh

# Download Nomad
echo Fetching Nomad...
cd /tmp/
wget https://dl.bintray.com/mitchellh/nomad/nomad_0.1.0_linux_amd64.zip -O nomad.zip

echo Installing Nomad...
unzip nomad.zip
sudo chmod +x nomad
sudo mv nomad /usr/bin/nomad

sudo mkdir /etc/nomad.d
sudo chmod a+w /etc/nomad.d

