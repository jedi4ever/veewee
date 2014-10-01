#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Install NFS client
apt-get -y install nfs-common
apt-get clean
