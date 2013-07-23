# Base install

. ./proxy.sh

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

cat > /etc/yum.repos.d/public-yum-ol6.repo << EOM
[ol6_latest]
name=Oracle Linux $releasever Latest (\$basearch)
baseurl=http://public-yum.oracle.com/repo/OracleLinux/OL6/latest/\$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1

[ol6_UEK_latest]
name=Latest Unbreakable Enterprise Kernel for Oracle Linux \$releasever (\$basearch)
baseurl=http://public-yum.oracle.com/repo/OracleLinux/OL6/UEK/latest/\$basearch/
gpgkey=http://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6
gpgcheck=1
enabled=1
EOM

wget "http://mirrors.kernel.org/fedora-epel/6Server/x86_64/epel-release-6-8.noarch.rpm"
rpm -Uvh epel-release-6-8.noarch.rpm

echo "UseDNS no" >> /etc/ssh/sshd_config

sed -i "s/^HOSTNAME=.*/HOSTNAME=vagrant.vagrantup.com/" /etc/sysconfig/network