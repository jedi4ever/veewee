#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Prepare puppetlabs repo
wget http://apt.puppetlabs.com/puppetlabs-release-precise.deb
dpkg -i puppetlabs-release-precise.deb
apt-get update

# Install puppet/facter
apt-get install -y puppet facter
