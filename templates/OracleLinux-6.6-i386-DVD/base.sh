# Base install

source ./proxy.sh

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

wget http://public-yum.oracle.com/public-yum-ol6.repo -O /etc/yum.repos.d/public-yum-ol6.repo
# UEK R3 Latest Channel NOT enabled by default

cd /tmp
wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm
rm -f /tmp/epel-release-6-8.noarch.rpm
# Not flexible to switch between direct Internet access and behind firewall
# --httpproxy HOST --httpport PORT
# rpm -ivh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm

echo "UseDNS no" >> /etc/ssh/sshd_config

sed -i "s/^HOSTNAME=.*/HOSTNAME=oracle.vagrantup.com/" /etc/sysconfig/network
