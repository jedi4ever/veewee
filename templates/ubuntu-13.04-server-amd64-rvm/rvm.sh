#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

curl -L get.rvm.io | bash -s stable
usermod --append --groups rvm vagrant
RVM=/usr/local/rvm/bin/rvm
$RVM install ree-1.8.7-2011.12
$RVM install 2.0.0-p195 
$RVM alias create default 2.0.0-p195
$RVM rubygems 1.8.25
