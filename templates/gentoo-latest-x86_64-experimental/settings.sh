# settings that will be shared between all scripts

cat <<DATAEOF > "/etc/profile.d/veewee.sh"
# stage 3 filename and full url
export stage3file="stage3-amd64-20130130.tar.bz2"
export stage3url="http://distfiles.gentoo.org/releases/amd64/current-stage3/\$stage3file"

# these two (configuring the compiler) and the stage3 url can be changed to build a 32 bit system
export accept_keywords="amd64"
export chost="x86_64-pc-linux-gnu"

# kernel version to use
export kernel_version="3.6.11"

# timezone (as a subdirectory of /usr/share/zoneinfo)
export timezone="UTC"

# locale
export locale="en_US.utf8"

# chroot directory for the installation
export chroot=/mnt/gentoo

# number of cpus in the host system (to speed up make and for kernel config)
export nr_cpus=$(</proc/cpuinfo grep processor|wc -l)

# user passwords for password based ssh logins
export password_root=vagrant
export password_vagrant=vagrant

# the public key for vagrants ssh
export vagrant_ssh_key_url="https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"
DATAEOF