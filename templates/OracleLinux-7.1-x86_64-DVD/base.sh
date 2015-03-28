# Base install

source ./proxy.sh

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

cd /tmp
wget http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
rpm -ivh epel-release-7-5.noarch.rpm
rm -f epel-release-7-5.noarch.rpm
# Not flexible to switch between direct Internet access and behind firewall
# --httpproxy HOST --httpport PORT
# rpm -ivh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm

echo "UseDNS no" >> /etc/ssh/sshd_config

hostnamectl set-hostname oraclelinux7.vagrant.vm

yum-config-manager --enable ol7_optional_latest

cat <<'EOF' > /etc/yum.repos.d/debuginfo.repo 
[debuginfo]
name=debuginfo
baseurl=https://oss.oracle.com/ol7/debuginfo/
gpgcheck=0
enabled=1
EOF
