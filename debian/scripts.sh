#!/bin/bash -ux

apt-get update -y || true
apt-get upgrade -y || true
apt-get dist-upgrade -y || true

apt-get -y install curl || true
apt-get -y install openssh-server || true
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config

if [ $(facter virtual) = 'virtualbox' ] ; then
    rm /etc/udev/rules.d/70-persistent-net.rules
    mkdir /etc/udev/rules.d/70-persistent-net.rules
    rm /lib/udev/rules.d/75-persistent-net-generator.rules
    rm -rf /dev/.udev/ /var/lib/dhcp/*
    echo "pre-up sleep 2" >> /etc/network/interfaces
fi

apt-get -y install sudo || true
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vagrant
chmod 440 /etc/sudoers.d/vagrant
echo "Defaults !requiretty" >> /etc/sudoers

### WARNING: DO NOT FORGET TO REMOVE IT IF ACCESSIBLE FROM OUTSIDE !!!

function add_vagrant_key {
    homedir=$(su - $1 -c 'echo $HOME')
    mkdir -p $homedir/.ssh
    curl -L 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -o $homedir/.ssh/authorized_keys2
    chown -Rf $1. $homedir/.ssh
    chmod 700 $homedir/.ssh
    chmod 600 $homedir/.ssh/authorized_keys2
}

if [ $(grep -c vagrant /etc/passwd) == 0 ] ; then
    useradd vagrant -m
fi

add_vagrant_key vagrant

mkdir /tmp/vbox
VER=$(cat /home/vagrant/.vbox_version)
mount -o loop /home/vagrant/VBoxGuestAdditions_$VER.iso /tmp/vbox 
yes | sh /tmp/vbox/VBoxLinuxAdditions.run
umount /tmp/vbox
rmdir /tmp/vbox
rm /home/vagrant/*.iso
ln -s /opt/VBoxGuestAdditions-*/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions

# Cleanup
rm -rf VBoxGuestAdditions_*.iso VBoxGuestAdditions_*.iso.?
rm -rf /usr/src/virtualbox-ose-guest*
rm -rf /usr/src/vboxguest*

# Clean up
apt-get -y --purge remove linux-headers-$(uname -r) build-essential || true
apt-get -y --purge autoremove || true
apt-get -y purge $(dpkg --list |grep '^rc' |awk '{print $2}')
apt-get -y purge $(dpkg --list |egrep 'linux-image-[0-9]' |awk '{print $3,$2}' |sort -nr |tail -n +2 |grep -v $(uname -r) |awk '{ print $2}')
apt-get -y clean || true

# Remove history file
unset HISTFILE
rm ~/.bash_history /home/vagrant/.bash_history

sync
