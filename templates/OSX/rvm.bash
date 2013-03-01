#!/bin/bash

curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash
source ~/.rvm/scripts/rvm

# http://stackoverflow.com/questions/11660673/install-ree-1-8-7-with-rvm-on-mountain-lion
# http://stackoverflow.com/questions/11664835/mountain-lion-rvm-install-1-8-7-x11-error/11666019#11666019
rvm install 1.8.7 \
	--with-gcc=clang \
	--without-tcl \
	--without-tk

rvm use 1.8.7 --default
rvm gemset create global
rvm use @global

exit
