#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Prepare puppetlabs repo
wget http://apt.puppetlabs.com/puppetlabs-release-lucid.deb
dpkg -i puppetlabs-release-lucid.deb
apt-get update

# Install puppet/facter
apt-get install -y puppet facter
