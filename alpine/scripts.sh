#!/bin/sh -ux

echo "alpine/3.3.1" > /etc/motd

apk update && apk upgrade
date > /etc/vagrant_box_build_time

apk add bash curl

adduser -D vagrant
echo "vagrant:vagrant" | chpasswd
mkdir -pm 700 /home/vagrant/.ssh
curl -sSo /home/vagrant/.ssh/authorized_keys 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub'
chown -R vagrant:vagrant /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

apk add sudo
adduser vagrant wheel
echo "Defaults exempt_group=wheel" > /etc/sudoers
echo "%wheel ALL=NOPASSWD:ALL" >> /etc/sudoers

rm -rf /var/cache/apk/*

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
sync

exit 0
