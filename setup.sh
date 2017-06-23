#!/bin/bash
release_info==$(cat /etc/*-release)
 
if [[ $(echo "$release_info" | grep 'Red Hat') != "" ]]; then 
    distro_type="redhat"; 
elif [[ $(echo "$release_info" | grep 'CentOS') != "" ]] ; then 
    distro_type="centos"; 
elif [[ $(echo "$release_info" | grep 'Ubuntu') != "" ]] ; then 
    distro_type="ubuntu"; 
elif [[ $(echo "$release_info" | grep 'Debian') != "" ]]; then 
    distro_type="debian"; 
elif [[ $(echo "$release_info" | grep 'Scientfic Linux') != "" ]]; then 
    distro_type="centos";
fi;

case "$distro_type" in
    "centos" | "redhat")
        sudo yum check-update
        sudo yum install -y gcc libffi-devel python-devel openssl-devel
        ;;
    "debian" | "ubuntu")
        #echo $distro_type
        
        #Install azure cli 2.0
        echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ wheezy main" | \
        sudo tee /etc/apt/sources.list.d/azure-cli.list
        sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 417A0893
        sudo apt-get install apt-transport-https
        sudo apt-get update && sudo apt-get install azure-cli
        ;;
esac

Retrieve commands which were uploaded from custom data and create shell script
mkdir -p /root/scripts
cat /var/lib/cloud/instance/user-data.txt > "/root/scripts/keyVault.sh"

# Register cron tab so when machine restart it downloads the secret from azure keyVault
chmod 700 /root/scripts/keyVault.sh
crontab -l > KeyVaultcron
echo "@reboot /root/scripts/keyVault.sh >> /root/scripts/log.txt" >> KeyVaultcron
crontab KeyVaultcron
rm KeyVaultcron

#Execute script
/root/scripts/keyVault.sh

exit 0
