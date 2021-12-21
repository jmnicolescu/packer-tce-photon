#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Deploy a Management Cluster to Docker 
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
echo "# Starting 50-tce-docker-deploy-management.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tce-build-variables.sh

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  exit 1
fi

echo "Pre-req check, increase connection tracking table size."
sudo sysctl -w net.netfilter.nf_conntrack_max=524288

echo "Pre-req check, ensure bootstrap machine has ipv4 and ipv6 forwarding enabled."
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo sysctl -w net.ipv4.ip_forward=1

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

echo "Create the management cluster"
tanzu management-cluster create -i docker --name ${MGMT_CLUSTER_NAME} --verbose 10 --plan dev --ceip-participation=false

echo "Sleeping 10 seconds ..."
sleep 10

# If Management cluster cration fails during the bootstrapping process
# export KUBECONFIG=`ls ${HOME}/.kube-tkg/tmp/config*`

# If Management cluster completes successfully
# Management cluster kubeconfig is saved to ${HOME}/.kube/config
export KUBECONFIG=${HOME}/.kube/config

kubectl get cluster -A
kubectl get machine  -A
kubectl get machinedeployment  -A 
kubectl get kubeadmcontrolplane -A
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

# Check management cluster details
tanzu management-cluster get

# Capture the management cluster’s kubeconfig 
export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
tanzu management-cluster kubeconfig get --admin

echo "Setting kubectl context to the management cluster."
kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}
kubectl get nodes -A

echo "Done 50-tce-docker-deploy-management.sh"