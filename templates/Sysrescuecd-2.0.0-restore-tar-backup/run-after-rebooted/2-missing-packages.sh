#! /bin/sh -xv

# needed lots of places
apt-get -y install sudo

# needed for base.sh
# THIS IS INTERACTIVE, AND SEEMS TO CONFLICT WITH EARLY GRUB STUFF
# - earlier grub stuff left empty grub files?
# - grub is also set later, in base.sh :/
#apt-get -y install grub

# needed for chef.sh
apt-get -y install make

# needed for non-free contrib source
apt-get -y install lsb-release

