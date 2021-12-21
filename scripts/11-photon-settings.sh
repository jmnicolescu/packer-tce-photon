#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Photon OS - First set of OS customization [ 11-photon-settings.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 11-photon-settings.sh"
echo "#--------------------------------------------------------------"

# Preserve FQDN hostname
touch /etc/cloud/cloud-init.disabled

echo '> Applying latest Updates...'
sudo sed -i 's/dl.bintray.com\/vmware/packages.vmware.com\/photon\/$releasever/g' /etc/yum.repos.d/*.repo
tdnf -y update photon-repos
tdnf clean all
tdnf makecache
tdnf -y update

echo "Installing Additional Packages..."
tdnf -y install logrotate zip unzip make autoconf tar gpg jq
tdnf -y install linux-esx python3-pip tmux

# setup profile
cat << 'PROFILE' > ${HOME}/.bash_profile
export TERM=xterm-color
export GREP_OPTIONS='--color=auto' GREP_COLOR='1;32'
export CLICOLOR=1

export HISTCONTROL=ignoredups:erasedups # no duplicate entries
export HISTSIZE=100000                  # big big history
export HISTFILESIZE=100000              # big big history
shopt -s histappend                     # append to history, don't overwrite it
PROFILE

# OS Specific Settings where ordering does not matter
set -euo pipefail

echo "Enable & Start SSH"
systemctl enable sshd
systemctl start sshd

echo "iptables - Allow ICMP"
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT
iptables-save > /etc/systemd/scripts/ip4save

## Issue #1 - Kind Known Issue - IPv6 Port Forwarding
## Docker assumes that all the IPv6 addresses should be reachable, hence doesn't implement port mapping using NAT

## Issue #2 - Pre-req check, ensure bootstrap machine has ipv4 forwarding enabled
## https://github.com/vmware-tanzu/tanzu-framework/issues/854


# Enable IPv4 and IPv6 forwarding
cat >> /etc/sysctl.conf << "EOF"
#
net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
net.ipv6.conf.all.disable_ipv6=0
EOF

cat >> /etc/sysctl.d/10-ip_forward.conf << "EOF"
net.ipv4.ip_forward=1
net.ipv6.conf.default.forwarding=1
EOF

# Docker/Tanzu requirement - Forward IPv4 or IPv6 source-routed packets
for SETTING in $(/sbin/sysctl -aN --pattern "net.ipv[4|6].conf.(all|default|eth.*).accept_source_route")
do 
    sed -i -e "/^${SETTING}/d" /etc/sysctl.conf
    echo "${SETTING}=1" >> /etc/sysctl.conf
done 

chmod 755 /root/scripts /root/scripts/*

echo "Done 11-photon-settings.sh"

