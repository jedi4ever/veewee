# Install Ruby

set -x

if [ -e ./proxy.sh ] ; then
  source ./proxy.sh
fi

yum -y install ruby ruby-devel rubygems
