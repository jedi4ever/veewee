# Base install

source ./proxy.sh

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

cd /etc/yum.repos.d
wget https://public-yum.oracle.com/public-yum-el5.repo

cd /tmp
wget http://download.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm
rpm -Uvh epel-release-5-4.noarch.rpm
rm -f /tmp/epel-release-5-4.noarch.rpm
# Not flexible to switch between direct Internet access and behind firewall
# --httpproxy HOST --httpport PORT
# rpm -ivh http://download.fedoraproject.org/pub/epel/5/x86_64/epel-release-5-4.noarch.rpm

echo "UseDNS no" >> /etc/ssh/sshd_config

sed -i "s/^HOSTNAME=.*/HOSTNAME=oracle.vagrantup.com/" /etc/sysconfig/network

yum -y install gcc make gcc-c++ kernel-devel-`uname -r` \
  kernel-uek-devel-`uname -r` zlib-devel openssl-devel \
  readline-devel sqlite-devel perl wget curl bzip2 dkms

yum -y update
