#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Photon OS - Configure NTP client [ 21-install-ntp-client.sh ]
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 21-install-ntp-client.sh" 
echo "#--------------------------------------------------------------"

cp /etc/systemd/timesyncd.conf /etc/systemd/timesyncd.conf.save

echo "NTP=pool.ntp.org" >> /etc/systemd/timesyncd.conf
echo "FallbackNTP=time.google.com" >> /etc/systemd/timesyncd.conf

# Restart the network service
systemctl restart systemd-networkd

#Restart the timesync service
systemctl restart systemd-timesyncd

echo "Done 21-install-ntp-client.sh"


