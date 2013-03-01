#!/bin/sh

# This uses Hashicorp's puppet-bootstrap script for OS X. We override
# the URLs because they're probably more recent than those in the script.

PUPPET=http://downloads.puppetlabs.com/mac/puppet-3.1.0.dmg
FACTER=http://downloads.puppetlabs.com/mac/facter-1.6.17.dmg

curl -Ok https://raw.github.com/hashicorp/puppet-bootstrap/master/mac_os_x.sh
chmod +x mac_os_x.sh

FACTER_PACKAGE_URL=$FACTER \
PUPPET_PACKAGE_URL=$PUPPET \
./mac_os_x.sh

rm mac_os_x.sh

exit
