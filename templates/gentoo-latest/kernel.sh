#!/bin/bash
source /etc/profile

# add required use flags and keywords
cat <<DATAEOF >> "$chroot/etc/portage/package.use/kernel"
sys-kernel/gentoo-sources symlink
sys-kernel/genkernel -cryptsetup
DATAEOF

cat <<DATAEOF >> "$chroot/etc/portage/package.accept_keywords/kernel"
dev-util/kbuild ~x86 ~amd64
DATAEOF

# get, configure, compile and install the kernel and modules
chroot "$chroot" /bin/bash <<DATAEOF
emerge =sys-kernel/gentoo-sources-$kernel_version sys-kernel/genkernel gentoolkit

cd /usr/src/linux
# use a default configuration as a starting point
make defconfig

# add settings for VirtualBox kernels to end of .config
cat <<EOF >>/usr/src/linux/.config
# dependencies
CONFIG_EXT4_FS=y
CONFIG_EXT4_USE_FOR_EXT23=y
CONFIG_EXT4_FS_XATTR=y
CONFIG_SMP=y
CONFIG_SCHED_SMT=y
CONFIG_MODULE_UNLOAD=y
CONFIG_DMA_SHARED_BUFFER=y
# for VirtualBox (http://en.gentoo-wiki.com/wiki/Virtualbox_Guest)
CONFIG_HIGH_RES_TIMERS=n
CONFIG_X86_MCE=n
CONFIG_SUSPEND=n
CONFIG_HIBERNATION=n
CONFIG_IDE=n
CONFIG_NO_HZ=y
CONFIG_SMP=y
CONFIG_ACPI=y
CONFIG_PNP=y
CONFIG_ATA=y
CONFIG_SATA_AHCI=y
CONFIG_ATA_SFF=y
CONFIG_ATA_PIIX=y
CONFIG_PCNET32=y
CONFIG_E1000=y
CONFIG_INPUT_MOUSE=y
CONFIG_DRM=y
CONFIG_SND_INTEL8X0=m
# for net fs
CONFIG_AUTOFS4_FS=m
CONFIG_NFS_V2=m
CONFIG_NFS_V3=m
CONFIG_NFS_V4=m
CONFIG_NFSD=m
CONFIG_CIFS=m
CONFIG_CIFS_UPCAL=y
CONFIG_CIFS_XATTR=y
CONFIG_CIFS_DFS_UPCALL=y
# for FUSE fs
CONFIG_FUSE_FS=m
# reduce size
CONFIG_NR_CPUS=$nr_cpus
CONFIG_COMPAT_VDSO=n
# propbably nice but not in defaults
CONFIG_MODVERSIONS=y
CONFIG_IKCONFIG_PROC=y
CONFIG_SQUASHFS=y
CONFIG_SQUASHFS_XATTR=y
CONFIG_SQUASHFS_XZ=y
# IPSec
CONFIG_NET_IPVTI=y
CONFIG_INET_AH=y
CONFIG_INET_ESP=y
CONFIG_INET_IPCOMP=y
CONFIG_INET_XFRM_MODE_TRANSPORT=y
CONFIG_INET_XFRM_MODE_TUNNEL=y
CONFIG_INET_XFRM_MODE_BEET=y
CONFIG_INET6_AH=y
CONFIG_INET6_ESP=y
CONFIG_INET6_IPCOMP=y
CONFIG_INET6_XFRM_MODE_TRANSPORT=y
CONFIG_INET6_XFRM_MODE_TUNNEL=y
CONFIG_INET6_XFRM_MODE_BEET=y
# crypto support
CONFIG_CRYPTO_USER=m
CONFIG_CRYPTO_CTS=y
CONFIG_CRYPTO_CTR=y
CONFIG_CRYPTO_RMD128=y
CONFIG_CRYPTO_RMD160=y
CONFIG_CRYPTO_RMD256=y
CONFIG_CRYPTO_RMD320=y
CONFIG_CRYPTO_SHA1_SSSE3=m
CONFIG_CRYPTO_SHA256=y
CONFIG_CRYPTO_SHA512=y
CONFIG_CRYPTO_AES_X86_64=y
CONFIG_CRYPTO_AES_NI_INTEL=m
CONFIG_CRYPTO_BLOWFISH_X86_64=y
CONFIG_CRYPTO_SALSA20_X86_64=y
CONFIG_CRYPTO_TWOFISH_X86_64_3WAY=y
CONFIG_CRYPTO_DEFLATE=y
# rtc
CONFIG_RTC=y
# devtmpfs, required by udev
CONFIG_DEVTMPFS=y
CONFIG_DEVTMPFS_MOUNT=y
EOF
# build and install kernel, using the config created above
genkernel --install --symlink --oldconfig --bootloader=grub all
DATAEOF
