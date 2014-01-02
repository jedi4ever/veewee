#!/bin/sh

# Remove VirtualBox Guest Additions ISO that the Veewee put in our
# home dir

rm -f ~/*.iso

# Install chef & puppet

su - vagrant -c 'gem install chef puppet --user-install \
  --bindir=$HOME/bin --no-rdoc --no-ri'

# Make sure we are totally up to date

nixos-rebuild --upgrade switch

# Cleanup any previous generations and delete old packages that can be
# pruned.

for x in `seq 0 2` ; do
    nix-env --delete-generations old
    nix-collect-garbage -d
done

# Zero out the disk (for better compression)

dd if=/dev/zero of=/EMPTY bs=1M
rm -rf /EMPTY
