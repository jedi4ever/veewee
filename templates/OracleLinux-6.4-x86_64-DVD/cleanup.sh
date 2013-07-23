yum remove -y \
byacc \
db4-devel \
epel-release \
freetype  \
gcc \
gcc-c++ \
gdbm-devel \
gtk2 \
hicolor-icon-theme \
kernel-uek-devel \
libffi-devel \
libyaml-devel \
libX11 \
make \
ncurses-devel \
openssl-devel \
readline-devel \
rpm-build \
rpmdevtools \
sqlite-devel \
tcl-devel \
zlib-devel

yum -y clean all
rm -rf VBoxGuestAdditions_*.iso