#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Upgrade all to the latest versions
apt-get -y update
apt-get -y upgrade
apt-get clean
