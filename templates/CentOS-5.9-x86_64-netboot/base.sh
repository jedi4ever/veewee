# Base install

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i "s/^\(.*env_keep = \"\)/\1PATH /" /etc/sudoers

# Use base URL for CentOS version 5.9 packages
sed -i "s/mirrorlist=/#mirrorlist=/" /etc/yum.repos.d/CentOS-Base.repo
sed -i "s/#baseurl=http:\/\/mirror.centos.org\/centos\/\$releasever\/\([a-z]\+\)\/.*/baseurl=http:\/\/vault.centos.org\/5.9\/\1\/x86_64/" /etc/yum.repos.d/CentOS-Base.repo

yum -y install gcc make gcc-c++ kernel-devel-`uname -r` zlib-devel openssl-devel readline-devel sqlite-devel perl wget dkms bzip2

yum -y erase gtk2 libX11 hicolor-icon-theme freetype bitstream-vera-fonts
