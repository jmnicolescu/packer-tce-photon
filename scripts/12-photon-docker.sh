#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Photon OS - Enable Docker [ 12-photon-docker.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 12-photon-docker.sh"
echo "#--------------------------------------------------------------"

## Setup daemon.
mkdir -p /etc/docker
mkdir -p /etc/systemd/system/docker.service.d

# https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file
cat << EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ],
  "ipv6": true,
  "fixed-cidr-v6": "2001:db8:1::/64"
}
EOF

echo "Downloading docker-compose..."
DOCKER_COMPOSE_VERSION=1.29.2
curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod 755 /usr/local/bin/docker-compose

echo "Enabling Docker..."
systemctl enable docker
systemctl start docker

echo "Done 12-photon-docker.sh"

