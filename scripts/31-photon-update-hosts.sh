#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Photon OS - Add static IP [ 31-photon-update-hosts.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# Update host entry in the /etc/hosts file using the current DHCP assigned IP
#
# More of a sample file as the interface differes from one platform to another
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 31-photon-update-hosts.sh"
echo "#--------------------------------------------------------------"

SHORT_HOST=`hostname`

echo "Updating /etc/hosts file."
sed -i '/'${SHORT_HOST}'/ d' /etc/hosts
ipaddr=`ifconfig ens192 | grep '10.8.' | awk '{ print $2}'`
echo "$ipaddr ${SHORT_HOST}.spr.bz ${SHORT_HOST}" >>/etc/hosts

systemctl restart systemd-networkd
systemctl restart systemd-resolved

echo "Done 31-photon-update-hosts"