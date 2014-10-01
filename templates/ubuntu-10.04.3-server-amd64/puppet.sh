#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

/opt/ruby/bin/gem install puppet --no-ri --no-rdoc
