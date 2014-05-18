# Base install

set -x

if [ -e ./proxy.sh ] ; then
  source ./proxy.sh
fi

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

# Pin YUM repositories to the specific version
yum-config-manager --enable ol6_u4_base
yum-config-manager --disable ol6_latest
yum-config-manager --enable ol6_UEK_base

# If we need the latest updates, uncomment the following lines
#yum-config-repo --enable public_ol6_latest
#yum -y update

# Install EPEL
rpm -ivh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

echo "UseDNS no" >> /etc/ssh/sshd_config

sed -i "s/^HOSTNAME=.*/HOSTNAME=oracle.vagrantup.com/" /etc/sysconfig/network

yum -y install gcc make gcc-c++ zlib-devel openssl-devel readline-devel sqlite-devel perl wget curl bzip2 dkms kernel-uek-devel-`uname -r`
