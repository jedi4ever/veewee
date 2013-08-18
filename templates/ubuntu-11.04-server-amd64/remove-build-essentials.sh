#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Remove items used for building, since they aren't needed anymore
apt-get -y remove linux-headers-$(uname -r) build-essential
apt-get -y autoremove
