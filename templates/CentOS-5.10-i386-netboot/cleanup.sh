# Clean up

yum -y clean all
rm -rf /etc/yum.repos.d/puppetlabs.repo
rm -rf VBoxGuestAdditions_*.iso

# Remove mac address from network configuration
sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-eth0

# Remove DHCP leases
rm /var/lib/dhclient/*.leases
