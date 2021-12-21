#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Create Standalone Docker Cluster
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# NOTE: If the Docker host machine is rebooted, the cluster will need 
#       to be re-created.
#
# Warning - Standalone clusters will be deprecated in a future release of Tanzu Community Edition
# Checkout the proposal for the standalone cluster replacement:
# https://github.com/vmware-tanzu/community-edition/issues/2266
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 52-tce-docker-deploy-standalone.sh.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tce-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  exit 1
fi

# We should really not do this, but it helps. Images' version are provided in the $TCE_VERSION BOM file.
pre_pull_array=( \
      "kindest/haproxy:v20210715-a6da3463" \
      "projects.registry.vmware.com/tkg/kind/node:v1.21.2_vmware.1" \
      )

for image in ${pre_pull_array[@]}; do
  echo "#-----------------------------------------------------------------------------------"
  echo "TCE ${TCE_VERSION}: Pre-pull $image "
  echo "#-----------------------------------------------------------------------------------"
  docker pull $image
done

echo "Sleeping 10 seconds ..."
sleep 10

echo "Create standalone cluster - ${CLUSTER_NAME}"
CLUSTER_PLAN=dev tanzu standalone-cluster create ${CLUSTER_NAME} -i docker --verbose 10

echo "Sleeping 10 seconds ..."
sleep 10

# If Standalone cluster cration fails during the bootstrapping process
# export KUBECONFIG=`ls ${HOME}/.kube-tkg/tmp/config*`

# If Standalone cluster completes successfully
# Management cluster kubeconfig is saved to ${HOME}/.kube/config

export KUBECONFIG=${HOME}/.kube/config
kubectl get pods -A
kubectl get deployments -A

# NAMESPACE      DEPLOYMENT NAME
# cert-manager   cert-manager
# cert-manager   cert-manager-cainjector
# cert-manager   cert-manager-webhook
# kube-system    antrea-controller
# kube-system    coredns
# tkg-system     kapp-controller
# tkg-system     tanzu-addons-controller-manager
# tkg-system     tanzu-capabilities-controller-manager
# tkr-system     tkr-controller-manager

# To access deployment logs
# kubectl logs deployment.apps/cert-manager -n cert-manager
# kubectl logs deployment.apps/antrea-controller -n kube-system
# kubectl logs deployment.apps/tkr-controller-manager -n tkr-system

echo "Setting kubectl context to the standalone cluster."
kubectl config use-context ${CLUSTER_NAME}-admin@${CLUSTER_NAME}

kubectl get nodes -A
kubectl get pods -A
kubectl get deployments -A

echo "Done 51-tce-docker-deploy-workload.sh"