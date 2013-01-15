#! /bin/sh

PASSWORD=vagrant

echo Setting Root Passwd to $PASSWORD
echo "root:$PASSWORD" | chpasswd

echo Setting the Vagrant user Password to $PASSWORD
echo "vagrant:$PASSWORD" | chpasswd
