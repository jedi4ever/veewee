
# Apt-install various things necessary for Ruby, guest additions,
# etc., and remove optional things to trim down the machine.
apt-get -y update
apt-get -y upgrade
apt-get -y install gcc build-essential linux-headers-$(uname -r)
apt-get -y install zlib1g-dev libssl-dev libreadline-gplv2-dev libyaml-dev
apt-get -y install vim curl
apt-get clean

# Setup sudo to allow no-password sudo for "sudo"
( cat <<'EOP'
Defaults exempt_group=vagrant
%vagrant ALL=NOPASSWD:ALL
EOP
) > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# Install NFS client
apt-get -y install nfs-common
