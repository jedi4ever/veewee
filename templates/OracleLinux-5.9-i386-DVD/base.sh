# Base install

. ./proxy.sh

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

cat > /etc/yum.repos.d/public-yum-el5.repo << EOM
[el5_latest]
name=Oracle Linux $releasever Latest (\$basearch)
baseurl=http://public-yum.oracle.com/repo/OracleLinux/OL5/latest/\$basearch/
gpgkey=http://public-yum.oracle.com/RPM-GPG-KEY-oracle-el5
gpgcheck=1
enabled=1

[ol5_UEK_latest]
name=Latest Unbreakable Enterprise Kernel for Oracle Linux \$releasever (\$basearch)
baseurl=http://public-yum.oracle.com/repo/OracleLinux/OL5/UEK/latest/\$basearch/
gpgkey=http://public-yum.oracle.com/RPM-GPG-KEY-oracle-el5
gpgcheck=1
enabled=1
EOM

wget "http://mirrors.kernel.org/fedora-epel/5Server/i386/epel-release-5-4.noarch.rpm"
rpm -Uvh epel-release-5-4.noarch.rpm

echo "UseDNS no" >> /etc/ssh/sshd_config

sed -i "s/^HOSTNAME=.*/HOSTNAME=vagrant.vagrantup.com/" /etc/sysconfig/network