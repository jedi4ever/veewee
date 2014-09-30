# clean up orphaned packages
package-cleanup --leaves | xargs yum erase -y

yum -y clean all

# rm -rf /etc/yum.repos.d/{puppetlabs,epel,epel-testing}.repo # keep
rm -rf VBoxGuestAdditions_*.iso

# Remove traces of mac address and uuid from network configuration
sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-enp0s3
sed -i /UUID/d /etc/sysconfig/network-scripts/ifcfg-enp0s3
