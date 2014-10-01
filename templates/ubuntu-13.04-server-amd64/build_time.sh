#!/bin/bash

if [ -f .veewee_params ]
then
  . .veewee_params
fi

date > /etc/vagrant_box_build_time
