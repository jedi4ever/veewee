# Install Chef

set -x

if [ -e ./proxy.sh ] ; then
  source ./proxy.sh
fi

curl -L https://www.opscode.com/chef/install.sh | bash
