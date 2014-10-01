#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

gem install puppet -v 3.2.2 --no-ri --no-rdoc
