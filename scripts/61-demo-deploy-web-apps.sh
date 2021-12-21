#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Deploy Demo Apps
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# NOTE: If the Docker host machine is rebooted, the cluster will need 
#       to be re-created.
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

export KUBECONFIG=${HOME}/.kube/config

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  exit 1
fi

echo "Adding TCE package repository..."

export REPO_NAME="tce-main-latest"
export REPO_URL="projects.registry.vmware.com/tce/main:0.9.1"
export REPO_NAMESPACE="default"

tanzu package repository add ${REPO_NAME} --namespace ${REPO_NAMESPACE} --url ${REPO_URL}
tanzu package repository get ${REPO_NAME} -o json | jq -r '.[0].status | select (. != null)'

echo "Sleeping 60 seconds ... wait for packages to be available"
sleep 60

echo "#--------------------------------------------------------------"
echo "TCE package repository -> Checking available package list ..."
echo "#--------------------------------------------------------------"
tanzu package available list

echo "#--------------------------------------------------------------"
echo "TCE package repository -> Checking installed package list ..."
echo "#--------------------------------------------------------------"
tanzu package installed list

## Demo #1

echo "Demo App #1: Installing fluent-bit -- Fluent Bit is a fast Log Processor and Forwarder"
tanzu package available list fluent-bit.community.tanzu.vmware.com

fluentbit_version=$(tanzu package available list fluent-bit.community.tanzu.vmware.com -o json | jq -r '.[0].version | select(. !=null)')
tanzu package install fluent-bit --package-name fluent-bit.community.tanzu.vmware.com --version "${fluentbit_version}"
tanzu package installed list
kubectl -n fluent-bit get all


## Demo #2

echo "Demo App #2: Installing assembly-webapp"
kubectl create namespace assembly
kubectl apply -f ${HOME}/scripts/61-assembly-deployment.yaml

echo "Waiting for assembly-webapp pods to be created."
for POD in `kubectl -n assembly get pods | grep -v NAME | awk '{print $1}'`
do
  kubectl -n assembly wait --for=condition=Ready pod/${POD} --timeout=120s
done

echo "Waiting for assembly-webapp pods to become available."
sleep 20

kubectl get pods,services --namespace=assembly
ExternalIp=`kubectl -n assembly get service/assembly-service | grep LoadBalancer | awk '{print $4}'`
echo " "
echo "To access assembly webapp, go to https://${ExternalIp}:8080"
echo " "

## To remove the assembly webapp
## kubectl delete --all  deployments,services,replicasets --namespace=assembly
## kubectl delete namespace assembly