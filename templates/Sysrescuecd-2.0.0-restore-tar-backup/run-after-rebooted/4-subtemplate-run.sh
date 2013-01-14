#! /bin/sh -xv
cd subtemplate
./base.sh
./ruby.sh 
./virtualbox.sh

./vagrant.sh

./chef.sh 
./puppet.sh 
#./cleanup-virtualbox.sh 
#./cleanup.sh 
#./zerodisk.sh
