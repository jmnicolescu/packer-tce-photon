
## Automate Tanzu Community Edition deployment to VMware vSphere or to Docker using a custom VM running Photon OS 3.0

#### Build features:

```
   Multiple deployment options: Vmware Fusion, Oracle VirtualBox, VMware ESXi, VMware vCenter.
   Build and deploy a custom Photon OS 3.0 VM to a target environment of choice.
   Install Tanzu Community Edition
   Deploy a Management Cluster to Docker as the target infrastructure provider 
   Deploy a Workload Cluster
   Deploy a Management Cluster to vSphere as the target infrastructure provider 
   Deploy a Workload Cluster
   Deploy Demo Apps, Fluent Bit and Kubernetes Dashboard

   TCE settings for deployment to Docker:
   Management Cluster Settings - Development - A management cluster with a single control plane node.
   Workload Cluster Settings   - Development - A workload cluster with a single worker node.

   TCE settings for deployment to VMware vSphere:
   Management Cluster Settings - Development - A management cluster with a single control plane node.
   Workload Cluster Settings   - Production - A workload cluster with three worker nodes.

```

#### References:

```
    TCE documentation
    https://tanzucommunityedition.io/docs/latest/
    
    TCE troubleshooting pages:
    https://github.com/vmware-tanzu/tanzu-framework/issues
```

#### Tanzu Community Edition component versions used in this project

```
   1. Tanzu Community Edition    v0.10.0-rc.2
   2. kubectl                    v1.22.4
   3. Kubernetes Node OS OVA     photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova
```

#### Software Requirements
 
```
   1. ISO: photon-3.0-a383732.iso
      Download Photon OS 3.0 Installation Media from https://github.com/vmware/photon/wiki/Downloading-Photon-OS
      https://packages.vmware.com/photon/3.0/Rev3/iso/photon-3.0-a383732.iso
      Copy photon-3.0-a383732.iso to the iso directory.

   2. OVA: photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova
      Download Kubernetes node OS OVA from VMware Customer Connect
      https://customerconnect.vmware.com/downloads/get-download?downloadGroup=TCE-090
      Copy photon-3-kube-v1.21.2+vmware.1-tkg.2-12816990095845873721.ova to the ova directory
```

## 1. VM Deployment

```
  # Manually set your environment variables, or read the secrets from pass and set them as environment variables
  export PKR_VAR_vcenter_hostname=$(pass provider_vcenter_hostname)
  export PKR_VAR_vcenter_username=$(pass provider_vcenter_username)
  export PKR_VAR_vcenter_password=$(pass provider_vcenter_password)
  export PKR_VAR_vm_access_username=$(pass vm_access_username)
  export PKR_VAR_vm_access_password=$(pass vm_access_password)
  export PKR_VAR_esx_remote_hostname=$(pass esx_remote_hostname)
  export PKR_VAR_esx_remote_username=$(pass esx_remote_username)
  export PKR_VAR_esx_remote_password=$(pass esx_remote_password)
```

#### Deployment to VMware Fusion

```
  # To deploy the custom Photon OS 3.0 VM to VMware Fusion run:
  packer build -var-file=photon3.pkrvars.hcl photon-fusion.pkr.hcl
```

#### Deployment to an ESXi host

```
  # To allow packer to work with the ESXi host - enable “Guest IP Hack”
  esxcli system settings advanced set -o /Net/GuestIPHack -i 1

  # To deploy the custom Photon OS 3.0 VM to an ESXi host run:
  packer build -var-file=photon3.pkrvars.hcl photon-esxi.pkr.hcl
```

#### Deployment to VMware vSphere

```
  # To deploy the custom Photon OS 3.0 VM to VMware vSphere run:
  packer build -var-file=photon3.pkrvars.hcl photon-vcenter.pkr.hcl
```

#### Deployment to Oracle VirtualBox

```
  # To deploy the custom Photon OS 3.0 VirtualBox VM in the OVF format:
  packer build -var-file=photon3.pkrvars.hcl photon-virtualbox.pkr.hcl
```

## 2. TCE installation and cluster configuration

#### TCE deployment to Docker

```
  login as user tce
  cd scripts

  # Update host entry in the /etc/hosts file using the current DHCP assigned IP
  sudo ./31-update-etc-hosts.sh

  # Reset Environment and Install Tanzu Community Edition
  ./33-install-tce

  # Deploy a Management Cluster to Docker 
  ./50-tce-docker-deploy-management.sh

  # Deploy a Workload Cluster to Docker
  ./51-tce-docker-deploy-workload.sh

  # Deploy Metallb Load Balancer
  ./60-demo-deploy-metallb.sh

  # Deploy Demo Apps and Fluent Bit
  ./61-demo-deploy-web-apps.sh

```

#### TCE deployment to VMware vSphere

```
  login as user tce
  cd scripts

  # Create a new GPG key
  gpg --gen-key

  # Initializing the Password Store using the new created PUBLIC_KEY_ID
  pass init PUBLIC_KEY_ID

  # Insert the user provider_vsphere_user in the password store
  pass insert provider_vsphere_user

  # Insert the password for provider_vsphere_password in the password store
  pass insert provider_vsphere_password

  # Update host entry in the /etc/hosts file using the current DHCP assigned IP
  sudo ./31-update-etc-hosts.sh

  # Reset Environment and Install Tanzu Community Edition
  ./33-install-tce

  # vSphere Requirerments, Deploy Kubernetes node OS VM 
  ./55-vsphere-deploy-k8s-ova

  # Deploy a Management Cluster to vSphere 
  ./56-vsphere-deploy-management.sh

  # Deploy a Workload Cluster to vSphere
  ./57-vsphere-deploy-workload.sh

  # Deploy Metallb Load Balancer
  ./60-demo-deploy-metallb.sh

  # Deploy Demo Apps and Fluent Bit
  ./61-demo-deploy-web-apps.sh

  # Deploy Kubernetes Dashboard
  ./62-demo-deploy-k8s-dashboard

```

## 3. Accessing the clusters

#### To access the management cluster, login as tce user and run:

```
  export MGMT_CLUSTER_NAME="tce-management"
  tanzu management-cluster kubeconfig get --admin
  kubectl config use-context ${MGMT_CLUSTER_NAME}-admin@${MGMT_CLUSTER_NAME}
  kubectl get nodes -A

  or just:
  export MGMT_CLUSTER_NAME="tce-management"
  export KUBECONFIG=${HOME}/.kube/config-${MGMT_CLUSTER_NAME}
  kubectl get nodes -A

  Note: ${HOME}/.kube/config-${MGMT_CLUSTER_NAME} is created during the install
```

#### To access the workload cluster, login as tce user and run:

```
  export WKLD_CLUSTER_NAME="tce-workload"
  tanzu cluster kubeconfig get ${WKLD_CLUSTER_NAME} --admin
  kubectl config use-context ${WKLD_CLUSTER_NAME}-admin@${WKLD_CLUSTER_NAME}
  kubectl get nodes -A
  
  or just:
  export KUBECONFIG=${HOME}/.kube/config-${WKLD_CLUSTER_NAME}
  kubectl get nodes -A

  Note: ${HOME}/.kube/config-${WKLD_CLUSTER_NAME} is created during the install
```
