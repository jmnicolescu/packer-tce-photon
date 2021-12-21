#----------------------------------------------------------------------------------
# Variable definition file to build the Photon OS 4.0 image
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# Downloading Photon OS
# https://github.com/vmware/photon/wiki/Downloading-Photon-OS
# Photon OS 4.0 Rev1 Binaries
# https://packages.vmware.com/photon/4.0/Rev1/iso/photon-4.0-ca7c9e933.iso
#----------------------------------------------------------------------------------

#----------------------------------------------------------------------------------
# Set your environment variables, or read the secrets from pass 
# and set them as environment variables
#
# export PKR_VAR_vcenter_hostname=$(pass provider_vcenter_hostname)
# export PKR_VAR_vcenter_username=$(pass provider_vcenter_username)
# export PKR_VAR_vcenter_password=$(pass provider_vcenter_password)
# export PKR_VAR_vm_access_username=$(pass vm_access_username)
# export PKR_VAR_vm_access_password=$(pass vm_access_password)
# export PKR_VAR_esx_remote_hostname=$(pass esx_remote_hostname)
# export PKR_VAR_esx_remote_username=$(pass esx_remote_username)
# export PKR_VAR_esx_remote_password=$(pass esx_remote_password)
#----------------------------------------------------------------------------------

vm_name                      = "photon"
vm_guest_os_type             = "vmware-photon-64"
vm_guest_version             = "19"
# vm_access_username         = # Reading PKR_VAR_vm_access_username environment variable
# vm_access_password         = # Reading PKR_VAR_vm_access_password environment variable
vm_ssh_timeout               = "15m"
cpu_count                    = "4"
ram_gb                       = "16"
vm_disk_size                 = "100000"

vm_iso_url                   = "iso/photon-4.0-ca7c9e933.iso"
# vm_iso_url                 = "https://packages.vmware.com/photon/4.0/Rev1/iso/photon-4.0-ca7c9e933.iso"
vm_iso_checksum              = "sha1:bec6359661b43ff15ac02b037f8028ae116dadb3"

boot_key_interval_iso        = "10ms"
boot_wait_iso                = "3s"
boot_keygroup_interval_iso   = "1s"

#----------------------------------------------------------------------------------
# Deployment to VMware vSphere - variables definition
#----------------------------------------------------------------------------------
# vcenter_hostname           = # Reading PKR_VAR_vcenter_username environment variable
# vcenter_username           = # Reading PKR_VAR_vcenter_username environment variable
# vcenter_password           = # Reading PKR_VAR_vcenter_password environment variable
vcenter_cluster              = "west-cluster"
vcenter_datacenter           = "west-dc"
vcenter_datastore            = "nfsdatastore01"
vcenter_folder               = "Templates"
vcenter_port_group           = "lab-mgmt"

#----------------------------------------------------------------------------------
# Deployment to VMware ESX - variables definition
#----------------------------------------------------------------------------------
# esx_remote_hostname        = # Reading PKR_VAR_esx_remote_hostname environment variable
# esx_remote_username        = # Reading PKR_VAR_esx_remote_username environment variable
# esx_remote_password        = # Reading PKR_VAR_esx_remote_password environment variable
esx_remote_type              = "esx5"
esx_remote_datastore         = "datastore1"
esx_port_group               = "PortG_Management"

#----------------------------------------------------------------------------------
# Deployment to VMware Fusion - variables definition
#----------------------------------------------------------------------------------
fusion_app_directory         = "/Applications/VMware Fusion.app"
fusion_output_directory      = "/Users/juliusn/Virtual Machines.localized/photon.vmwarevm"
