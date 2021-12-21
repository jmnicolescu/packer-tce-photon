#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Photon OS - Add static IP [ 30-photon-add-static-ip.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#
# More of a sample file as the interface differes from one platform to another
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 30-photon-add-static-ip.sh"
echo "#--------------------------------------------------------------"

STATIC_IP="192.168.111.126"
SHORT_HOST=`hostname`

cat > /etc/systemd/network/10-static-en.network << "EOF"
[Match]
Name=eth0

[Network]
DHCP=no
Address=${STATIC_IP}/24
Gateway=192.168.111.1
DNS=192.168.111.111
EOF

echo "Updating /etc/hosts file."
sed -i '/'${SHORT_HOST}'/ d' /etc/hosts
ipaddr=`ifconfig ens192 | grep '10.8.' | awk '{ print $2}'`
echo "$ipaddr ${SHORT_HOST}.spr.bz ${SHORT_HOST}" >>/etc/hosts

chmod 644 /etc/systemd/network/10-static-en.network
rm -f /etc/systemd/network/99-dhcp-en.network

systemctl restart systemd-networkd
systemctl restart systemd-resolved

echo "Done 30-photon-add-static-ip"