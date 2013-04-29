# Base install

# Enable updates-testing repo
sed -i "s/enabled=0/enabled=1/" /etc/yum.repos.d/fedora-updates-testing.repo

# Must exclude kernel for now. Otherwise, kernel gets upgraded before reboot,
# but VirtualBox tools get compiled against the old kernel, so the fresh
# image will refuse to start under Vagrant.
yum -y update --exclude kernel*

yum -y install gcc make gcc-c++ kernel-devel-`uname -r` zlib-devel openssl-devel readline-devel sqlite-devel perl wget dkms tar bzip2 net-tools

