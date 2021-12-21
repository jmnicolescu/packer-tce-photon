#!/bin/bash -eu

#--------------------------------------------------------------------------
# Tanzu Community Edition - Deploy Kubernetes node OS VM [ 55-tce-vsphere-deploy-k8s-ova.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version, using govc
#
#
# Download the OVA that matches the Kubernetes node OS from VMware Customer Connect
# https://customerconnect.vmware.com/downloads/get-download?downloadGroup=TCE-090
#
# photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova
# SHA256SUM: 863eed478fd6a21232cb49b70cda1c1c6788b454c7b5305acf3059570f5eb6b1
#
# ubuntu-2004-kube-v1.21.2+vmware.1-tkg.1-7832907791984498322.ova
# SHA256SUM: 0965e49810b57ded9f1d28382da967997e58004ffab729a59a7c65fe645f03f0
#
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------

############################################################################
##
## Store vCenter secrets by using the pass insert command:
##
##     pass insert provider_vcenter_hostname
##     pass insert provider_vcenter_username
##     pass insert provider_vcenter_password
##
#############################################################################

echo "#--------------------------------------------------------------"
echo "# Starting 55-tce-vsphere-deploy-k8s-ova.sh" 
echo "#--------------------------------------------------------------"

source ${HOME}/scripts/00-tce-build-variables.sh
echo $$ > ${HOME}/scripts/.index

echo "Creating Resource Pool to deploy the Tanzu Community Edition Instance"
govc pool.create "/${VSPHERE_DATACENTER}/host/${VSPHERE_CLUSTER}/Resources/${VSPHERE_RESOURCE_POOL}"
govc pool.info   "/${VSPHERE_DATACENTER}/host/${VSPHERE_CLUSTER}/Resources/${VSPHERE_RESOURCE_POOL}"

echo "Creating VM folder in which to collect the Tanzu Community Edition VMs"
govc folder.create "/${VSPHERE_DATACENTER}/vm/${VSPHERE_FOLDER}"
govc folder.info   "/${VSPHERE_DATACENTER}/vm/${VSPHERE_FOLDER}"

# Extract the ova-specs from the ova image
# govc import.spec ${OVA_FILE} | jq . > ${OVA_JSON_FILE}

echo "Updating ova-specs file with the Network info [ $VSPHERE_NETWORK_PG ]"
cat > ${OVA_JSON_FILE} << EOF
{
  "DiskProvisioning": "flat",
  "IPAllocationPolicy": "dhcpPolicy",
  "IPProtocol": "IPv4",
  "NetworkMapping": [
    {
      "Name": "nic0",
      "Network": "${VSPHERE_NETWORK_PG}"
    }
  ],
  "Annotation": "Cluster API vSphere image - VMware Photon OS 64-bit and Kubernetes v1.21.2+vmware.1",
  "MarkAsTemplate": true,
  "PowerOn": false,
  "InjectOvfEnv": false,
  "WaitForIP": false,
  "Name": null
}
EOF

echo "-----------------------------------------------------------------------------------------"
echo "Deploying Kubernetes node OS VM and converting the VM to Template."
echo "OVA file:          ${OVA_FILE}"
echo "OVA specs file:    ${OVA_JSON_FILE}"
echo "VM name:           ${OVA_VM_NAME}"
echo "TCE folder:        ${VSPHERE_FOLDER}"
echo "-----------------------------------------------------------------------------------------"

govc import.ova -ds=${VSPHERE_DATASTORE} -folder=${VSPHERE_FOLDER} -pool=${VSPHERE_RESOURCE_POOL} -name=${OVA_VM_NAME} \
   -options="${OVA_JSON_FILE}" ${OVA_FILE}

echo "Creating a new SSH Key Pair."
ssh-keygen -q -b 4096 -t rsa -N '' -f ~/.ssh/id_rsa 2>/dev/null <<< y >/dev/null

echo "-----------------------------------------------------------------------------------------"
more ${HOME}/.ssh/id_rsa.pub 
echo "-----------------------------------------------------------------------------------------"
  
echo "Done 55-tce-vsphere-deploy-k8s-ova.sh"