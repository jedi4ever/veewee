# Set sources.list to long term support repository.
echo "deb http://httpredir.debian.org/debian/ squeeze main contrib non-free
deb-src http://httpredir.debian.org/debian/ squeeze main contrib non-free
deb http://httpredir.debian.org/debian squeeze-lts main contrib non-free
deb-src http://httpredir.debian.org/debian squeeze-lts main contrib non-free" > /etc/apt/sources.list

# Update the box
export DEBIAN_FRONTEND="noninteractive"
apt-get -qq update
apt-get -qq upgrade
apt-get -qq dist-upgrade
apt-get -qq install linux-headers-$(uname -r) build-essential
apt-get -qq install zlib1g-dev libssl-dev libreadline5-dev
apt-get -qq install curl unzip
apt-get clean

# Set up sudo
cp /etc/sudoers /etc/sudoers.orig
sed -i -e 's/%sudo ALL=(ALL) ALL/%sudo ALL=NOPASSWD:ALL/g' /etc/sudoers

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
echo <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF

update-grub
