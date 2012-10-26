# Base install

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers

cat > /etc/yum.repos.d/public-yum-ol6.repo << EOM
[ol6_u3_base]
name=Oracle Linux $releasever Update 3 installation media copy (\$basearch)
baseurl=http://public-yum.oracle.com/repo/OracleLinux/OL6/3/base/\$basearch/
gpgkey=http://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6
gpgcheck=1
enabled=1

[ol6_UEK_latest]
name=Latest Unbreakable Enterprise Kernel for Oracle Linux \$releasever (\$basearch)
baseurl=http://public-yum.oracle.com/repo/OracleLinux/OL6/UEK/latest/\$basearch/
gpgkey=http://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6
gpgcheck=1
enabled=1
EOM

cat > /etc/yum.repos.d/epel.repo << EOM
[epel]
name=epel
baseurl=http://download.fedoraproject.org/pub/epel/6/\$basearch
enabled=1
gpgcheck=0
EOM

yum -y install gcc make gcc-c++ kernel-devel-`uname -r` kernel-uek-devel-`uname -r` zlib-devel openssl-devel readline-devel sqlite-devel perl wget

