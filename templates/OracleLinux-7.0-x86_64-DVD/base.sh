# Base install

source ./proxy.sh

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

cd /tmp
wget http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm
rpm -ivh epel-release-7-1.noarch.rpm
rm -f epel-release-7-1.noarch.rpm
# Not flexible to switch between direct Internet access and behind firewall
# --httpproxy HOST --httpport PORT
# rpm -ivh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm

echo "UseDNS no" >> /etc/ssh/sshd_config

hostnamectl set-hostname oraclelinux7.vagrant.vm

yum-config-manager --enable ol7_optional_latest
