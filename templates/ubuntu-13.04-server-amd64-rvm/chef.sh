#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

gem install chef -v 11.4.4 --no-ri --no-rdoc
