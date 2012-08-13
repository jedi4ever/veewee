curl https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer | bash -s stable

source /etc/profile.d/rvm.sh

yum install -y gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison

rvm --force reinstall ruby-1.9.3

rvm --default use 1.9.3
