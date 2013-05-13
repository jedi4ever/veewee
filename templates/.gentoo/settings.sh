# settings that will be shared between all scripts

cat <<DATAEOF > "/etc/profile.d/veewee.sh"

stage3current=\`curl -s http://distfiles.gentoo.org/releases/\${build_arch}/autobuilds/latest-stage3-\${build_proc}.txt|grep -v "^#"\`
export stage3url="http://distfiles.gentoo.org/releases/\${build_arch}/autobuilds/\${stage3current}"
export stage3file=\${stage3current##*/}

# timezone (as a subdirectory of /usr/share/zoneinfo)
# implementation --> base.sh:79
# export timezone="Europe/Lisbon" # for example
export timezone="UTC"

# choose your SYNC server regarding your country
# check this page for more details http://www.gentoo.org/main/en/mirrors-rsync.xml
# if empty, it will default to the default gentoo rotation
# implementation --> base.sh:91
# country_code = ".us" # for example
# country_code = ".fr" # for another example
export country_code=""

# find the 3 fastest GENTOO_MIRRORS 
# if set to TRUE, it will download packets from all the mirrors and find the 3 fastest
# (add 15mins to the build)
# implementation --> base.sh:96
export fastest_mirror=false

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

# choose your ruby version when you install it from source
export libyaml_version="0.1.4"
export ruby_version="1.9.3-p392"

DATAEOF
