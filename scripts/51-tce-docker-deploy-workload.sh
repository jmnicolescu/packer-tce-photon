#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Deploy a Workload Cluster to Docker
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# NOTE: If the Docker host machine is rebooted, the cluster will need 
#       to be re-created.
#
# Documentation:
# https://tanzucommunityedition.io/docs/latest/docker-install-mgmt/
# 
# For help in troubleshooting TCE issues go to:
# https://github.com/vmware-tanzu/tanzu-framework/issues
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 51-tce-docker-deploy-workload.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tce-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  exit 1
fi

# Check management cluster details
tanzu management-cluster get

# Capture the management cluster’s kubeconfig
export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
# tanzu management-cluster kubeconfig get --admin

echo "Setting kubectl context to the management cluster."
kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}

echo "Create the workload cluster"
tanzu cluster create ${WKLD_CLUSTER_NAME} --plan dev

echo "Sleeping 10 seconds ... wait for the cluster ${WKLD_CLUSTER_NAME} to be available"
sleep 10

tanzu cluster list

# Capture the workload cluster’s kubeconfig
export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}
tanzu cluster kubeconfig get ${WKLD_CLUSTER_NAME} --admin
cp ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} ${HOME}/.kube/config

echo "Setting kubectl context to the management cluster."
kubectl config use-context ${WKLD_CLUSTER_NAME}-admin@${WKLD_CLUSTER_NAME}
kubectl get nodes -A

echo "Done 51-tce-docker-deploy-workload.sh"