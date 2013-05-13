# settings that will be shared between all scripts

cat <<DATAEOF > "/etc/profile.d/architecture.sh"
# retrieve from Gentoo current autobuild txt - these change regularly
export build_arch="amd64"
export build_proc="amd64"

# for grub
export kernel_architecture="x86_64"

# for the compiler
export chost="x86_64-pc-linux-gnu"

DATAEOF
