#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

# Installing chef
/opt/ruby/bin/gem install chef --no-ri --no-rdoc
