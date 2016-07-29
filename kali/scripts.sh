#!/bin/bash -eux

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y

# Build tools

apt-get install -y zlib1g-dev libreadline-gplv2-dev curl wget unzip vim

# Kali

echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free' > /etc/apt/sources.list.d/kali.list
wget -q -O - https://www.kali.org/archive-key.asc | gpg --import

apt-get -y update
apt-get -y --force-yes install kali-archive-keyring

debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password'    
debconf-set-selections <<< 'mysql-server-5.5 mysql-server-5.5/postrm_remove_databases boolean false'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server-5.5/start_on_boot boolean true'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server-5.5/nis_warning note'  
debconf-set-selections <<< 'mysql-server-5.5 mysql-server-5.5/really_downgrade boolean false'
debconf-set-selections <<< 'kismet kismet/install-setuid boolean false'
debconf-set-selections <<< 'kismet kismet/install-users string'
debconf-set-selections <<< 'sslh sslh/inetd_or_standalone select standalone'

apt-get -y --force-yes install kali-linux kali-desktop-live kali-linux-full desktop-base xfce4 xfce4-places-plugin xfce4-goodies
apt-get -y --force-yes upgrade
apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy dist-upgrade

# Theme

wget http://download.opensuse.org/repositories/home:Horst3180/Debian_8.0/Release.key
apt-key add - < Release.key
echo 'deb http://download.opensuse.org/repositories/home:/Horst3180/Debian_8.0/ /' > /etc/apt/sources.list.d/arc-theme.list 
apt-get -y update
apt-get install arc-theme

# Clean up

apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove --purge
apt-get -y clean

rm /var/lib/dhcp/*
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

echo "pre-up sleep 2" >> /etc/network/interfaces

history -c
history -w
