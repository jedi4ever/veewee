# settings that will be shared between all scripts

cat <<DATAEOF > "/etc/profile.d/architecture.sh"
# retrieve from Gentoo current autobuild txt - these change regularly
export build_arch="x86"
export build_proc="i686"

# for grub
export kernel_architecture="x86"

# for the compiler
export chost="i686-pc-linux-gnu"

DATAEOF
