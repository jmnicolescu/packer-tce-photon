#!/bin/bash -eu

#--------------------------------------------------------------------------------------
# Add Users - [ 19-user-settings.sh ] - Add users - tce, tkg, juliusn
# juliusn - Sun Dec  5 08:48:39 EST 2021 - first version
#--------------------------------------------------------------------------------------

echo "#--------------------------------------------------------------"
echo "# Starting 19-user-settings.sh" 
echo "#--------------------------------------------------------------"

groupadd  -g 501 juliusn
useradd -g 501 -u 501 -m -s /bin/bash -p '$6$sjGTQ15bOR/6/e28$wSHYlo.5ZdxQtFQDAQVQ4mEBgjVrZX.CZ.s1OaPTJqxcPpcKSzd2sQ/kNCEFdefN8WfEtNiSO953g1TaIUhJA/' juliusn
usermod -aG docker juliusn
echo "juliusn  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/juliusn

groupadd  -g 1501 tce
useradd -g 1501 -u 1501 -m -s /bin/bash -p '$6$x7wbk2Gb$r6AwgsugMa842WhekbpYmFB5ObIMcwoJtePJxlpSq1mXxsTH/pYVBYrTf8KT5tR/bJ1gyZ2dDHNlRkNaraqZ/0' tce
usermod -aG docker tce
echo "tce  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/tce

groupadd  -g 1502 tkg
useradd -g 1502 -u 1502 -m -s /bin/bash -p '$6$x7wbk2Gb$r6AwgsugMa842WhekbpYmFB5ObIMcwoJtePJxlpSq1mXxsTH/pYVBYrTf8KT5tR/bJ1gyZ2dDHNlRkNaraqZ/0' tkg
usermod -aG docker tkg
echo "tce  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/tkg

# create ssh-keys for root
ssh-keygen -q -b 4096 -t rsa -N '' -f ~/.ssh/id_rsa 2>/dev/null <<< y >/dev/null

for myuser in "tce" "tkg" "juliusn"
do
    echo "Updating files and profile for user ${myuser}"
    su - ${myuser} -c "ssh-keygen -q -b 4096 -t rsa -N '' -f ~/.ssh/id_rsa 2>/dev/null <<< y >/dev/null"

    cat << 'PROFILE' >> /home/${myuser}/.bash_profile
##
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
## GOVC NOTE
##
## Store vCenter secrets by using the pass insert command:
##     pass insert provider_vcenter_hostname
##     pass insert provider_vcenter_username
##     pass insert provider_vcenter_password
##
export GOVC_URL="https://$(pass provider_vcenter_hostname)"
export GOVC_USERNAME=$(pass provider_vcenter_username)
export GOVC_PASSWORD=$(pass provider_vcenter_password)
export GOVC_INSECURE=true
PROFILE

    mkdir -p /home/${myuser}/scripts
    cp /root/scripts/[0,3,5,6]* /home/${myuser}/scripts
    chown -R ${myuser}:${myuser} /home/${myuser}/scripts /home/${myuser}/.bash_profile
done

echo "Done 19-user-settings.sh"