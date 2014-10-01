#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Install Chef
curl -L https://www.opscode.com/chef/install.sh | sudo bash
