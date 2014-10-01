#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

GEM=/opt/ruby/bin/gem

$GEM install chef --no-ri --no-rdoc
