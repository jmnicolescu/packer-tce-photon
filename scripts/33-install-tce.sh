#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Install / ReInstall [33-install-tce.sh]
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 33-install-tce.sh"
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tce-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  echo "Done 33-install-tce.sh"
  exit 1
fi

rm -rf ${HOME}/.kube-tkg ${HOME}/.kube
rm -rf ${HOME}/.tanzu ${HOME}/.config/tanzu  ${HOME}.cache/tanzu

# Install Tanzu Community Edition
echo "Installing Install Tanzu Community Edition from ${HOME}/tce-linux-amd64-v${TCE_VERSION}"
cd ${HOME}/tce-linux-amd64-v${TCE_VERSION}
./uninstall.sh
./install.sh

# Checking Tanzu version
tanzu version
tanzu plugin list

echo "Done 33-install-tce.sh"