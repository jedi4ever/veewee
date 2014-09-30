#! /bin/sh -xv
cd subtemplate
sh ./base.sh
sh ./ruby.sh 
sh ./virtualbox.sh

sh ./vagrant.sh

sh ./chef.sh 
sh ./puppet.sh 
sh ./cleanup-virtualbox.sh 
sh ./cleanup.sh 
#sh ./zerodisk.sh
