yum -y remove gtk2 libX11 hicolor-icon-theme avahi freetype bitstream-vera-fonts
yum -y clean all

# rm -rf /etc/yum.repos.d/{puppetlabs,epel,epel-testing}.repo # keep
rm -rf VBoxGuestAdditions_*.iso

# Remove traces of mac address from network configuration
sed -i /HWADDR/d /etc/sysconfig/network-scripts/ifcfg-eth0
