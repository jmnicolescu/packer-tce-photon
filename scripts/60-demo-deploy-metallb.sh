#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Deploy Load Balancer
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# MetalLB - https://metallb.universe.tf/
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

source ${HOME}/scripts/00-tce-build-variables.sh

export KUBECONFIG=${HOME}/.kube/config

if [[ "$EUID" -eq 0 ]]; then
  echo "Do not run this script as root"
  exit 1
fi

echo "Install MetalLB, apply the manifest"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml

echo "Waiting for pods to be created."
for POD in `kubectl -n metallb-system get pods | grep -v NAME | awk '{print $1}'`
do
  kubectl -n metallb-system wait --for=condition=Ready pod/${POD} --timeout=120s
done

echo "Create the metallb configuration which will define the IP Address range that will be allocated for load balancer requests"
cat > ${HOME}/scripts/metallb-config.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - ${METALLB_VIP_RANGE}
EOF

echo "Waiting for pods to become available."
sleep 10

kubectl apply -n metallb-system -f ${HOME}/scripts/metallb-config.yaml

echo "Verify that all metallb Pods are running."
kubectl -n metallb-system get pods