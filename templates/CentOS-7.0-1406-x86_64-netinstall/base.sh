# Base install

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

yum install -y epel-release

#cat > /etc/yum.repos.d/epel.repo << EOM
#[epel]
#name=epel
#baseurl=http://download.fedoraproject.org/pub/epel/7/x86_64/\$basearch
#enabled=1
#gpgcheck=0
#EOM

yum -y install gcc make gcc-c++ kernel-devel-`uname -r` zlib-devel openssl-devel readline-devel sqlite-devel perl wget dkms nfs-utils bzip2

# Make ssh faster by not waiting on DNS
echo "UseDNS no" >> /etc/ssh/sshd_config
