#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Download Tanzu Community Edition [32-download-tanzu-tce.sh]
#
# Download pages:
# https://github.com/vmware-tanzu/community-edition/releases
# https://www.downloadkubernetes.com/
# https://octant.dev/
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 30-download-tanzu-tce.sh"
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tce-build-variables.sh

# Download and Install Tanzu Community Edition

echo "Download and Install Tanzu Community Edition release ${TCE_VERSION}"
curl -LO https://github.com/vmware-tanzu/community-edition/releases/download/v${TCE_VERSION}/tce-linux-amd64-v${TCE_VERSION}.tar.gz
tar xzvf tce-linux-amd64-v${TCE_VERSION}.tar.gz 

# Copy TCE to tce user home directory

cp tce-linux-amd64-v${TCE_VERSION}.tar.gz  /home/tce/tce-linux-amd64-v${TCE_VERSION}.tar.gz
chown tce:tce /home/tce/tce-linux-amd64-v${TCE_VERSION}.tar.gz
su - tce -c "cd /home/tce ; tar xzvf tce-linux-amd64-v${TCE_VERSION}.tar.gz"

# Copy TCE to juliusn user home directory

cp tce-linux-amd64-v${TCE_VERSION}.tar.gz  /home/juliusn/tce-linux-amd64-v${TCE_VERSION}.tar.gz
chown juliusn:juliusn /home/juliusn/tce-linux-amd64-v${TCE_VERSION}.tar.gz
su - juliusn -c "cd /home/juliusn ; tar xzvf tce-linux-amd64-v${TCE_VERSION}.tar.gz"

# Download and install kubectl

echo "Download and install kubectl version ${K8S_VERSION}"
curl -LO https://dl.k8s.io/release/v${K8S_VERSION}/bin/linux/amd64/kubectl
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Download and install kind

echo "Download and install kind version ${KIND_VERSION}"
curl -LO https://kind.sigs.k8s.io/dl/v${KIND_VERSION}/kind-linux-amd64
install -o root -g root -m 0755 kind-linux-amd64 /usr/local/bin/kind

# Download and install Octant

echo "Download and install Octant version ${OCTANT_VERSION}"
curl -LO https://github.com/vmware-tanzu/octant/releases/download/v${OCTANT_VERSION}/octant_${OCTANT_VERSION}_Linux-64bit.tar.gz
tar xzvf octant_${OCTANT_VERSION}_Linux-64bit.tar.gz
install -o root -g root -m 0755 octant_${OCTANT_VERSION}_Linux-64bit/octant /usr/local/bin/octant

rm -f /home/tce/tce-linux-amd64-v${TCE_VERSION}.tar.gz /home/juliusn/tce-linux-amd64-v${TCE_VERSION}.tar.gz
rm -f tce-linux-amd64-v${TCE_VERSION}.tar.gz kubectl kind-linux-amd64 octant_${OCTANT_VERSION}_Linux-64bit.tar.gz

# Download and Install Helm 3

echo "Download and install Helm 3"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo "Done 30-download-tanzu-tce.sh"
