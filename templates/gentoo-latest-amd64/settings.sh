# settings that will be shared between all scripts

cat <<DATAEOF > "/etc/profile.d/veewee.sh"
# stage 3 filename and full url
# retrieve from Gentoo current autobuild txt - these change regularly

# distfiles source
distfiles_url=http://distfiles.gentoo.org

build_arch="amd64"
build_proc="amd64"
stage3current=\`curl -s \${distfiles_url}/releases/\${build_arch}/autobuilds/latest-stage3-\${build_proc}.txt|grep -v "^#"\`
export stage3url="\${distfiles_url}/releases/\${build_arch}/autobuilds/\${stage3current}"
export stage3file=\${stage3current##*/}
export portageurl="\${distfiles_url}/snapshots/portage-latest.tar.bz2"

# these two (configuring the compiler) and the stage3 url can be changed to build a 32 bit system
export accept_keywords="amd64"
export chost="x86_64-pc-linux-gnu"

# kernel version to use
export kernel_version="3.10.7-r1"
export kernel_image_version="3.10.7-gentoo-r1"

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
