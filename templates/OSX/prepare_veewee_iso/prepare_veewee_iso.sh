#!/bin/sh
#
# Preparation script for an OS X automated installation for use with VeeWee/Vagrant
#
# Usage:
# sudo prepare_veewee_iso.sh /path/to/OSXinstaller.app.or.dmg /path/to/veewee/iso/my-new-iso.dmg
#
# and configure this iso in your definition. You must run this with root privileges, because
# it should be mounted with ownerships respected.
# 
# What the script does, in more detail:
# 
# 1. Mounts the InstallESD.dmg using a shadow file, so the original DMG is left
#    unchanged.
# 2. Depending on the version of OS X being built, the AutoPartition.app from
#    System Image Utility is copied to the ISO's 'Packages/Extra' directory.
#    A 10.7 image requires a download of Apple's Server Admin Tools package in
#    order to extract this utility, so this is done if needed. AutoPartition.app
#    makes use of PartitionInfo.plist, which is also copied over.
# 3. minstallconfig.xml and PartitionInfo.plist are also copied, which are looked
#    for by the installer environment's rc.* files that first load with the system.
#    This allows us to never actually modify the BaseSystem.dmg and only drop in
#    these extra files.
# 3. A 'veewee-config.pkg' installer package is built, which is added to the OS X
#    install by way of the OSInstall.collection file. This package creates the
#    'vagrant' user, configures sshd and sudoers, and disables setup assistants.
# 4. veewee-config.pkg and the various support utilities are copied, and the disk
#    image is saved to the output path.
#
#
# Idea and much of the implementation thanks to Pepijn Bruienne, who's also provided
# some process notes here: https://gist.github.com/4542016. The sample minstallconfig.xml,
# use of OSInstall.collection and readme documentation provided with Greg Neagle's
# createOSXInstallPkg tool also proved very helpful. (http://code.google.com/p/munki/wiki/InstallingOSX)
# User creation via package install method also credited to Greg.
#
# TODO:
# - explicitly set a shadowfile path, so we don't depend on the source ESD being on a writable volume
# - support loading environment details so we can copy to an alternate iso_dir
# - rewrite this thing in Python

usage() {
	cat <<EOF
Usage:
$(basename "$0") "/path/to/InstallESD.dmg" [/path/to/output/directory]
$(basename "$0") "/path/to/Install OS X [Mountain] Lion.app" [/path/to/output/directory]

Description:
Converts a 10.7/10.8 installer image to a new image that contains components
used to perform an automated installation. If the second argument is omitted,
it will be installed to 'veewee/iso/'. The new image will be named 'OSX_InstallESD_[osversion].dmg.'

EOF
}

msg_status() {
	echo "\033[0;32m-- $1\033[0m"
}
msg_error() {
	echo "\033[0;31m-- $1\033[0m"
}

if [ $# -eq 0 ]; then
	usage
	exit 1
fi

if [ $(id -u) -ne 0 ]; then
	msg_error "This script must be run as root, as it saves a disk image with ownerships enabled."
	exit 1
fi	

ESD="$1"
if [ ! -e "$ESD" ]; then
	msg_error "Input installer image $ESD could not be found! Exiting.."
	exit 1
fi

if [ -d "$ESD" ]; then
	# we might be an install .app
	if [ -e "$ESD/Contents/SharedSupport/InstallESD.dmg" ]; then
		ESD="$ESD/Contents/SharedSupport/InstallESD.dmg"
	else
		msg_error "Can't locate an InstallESD.dmg in this source location $ESD!"
	fi
fi

SCRIPT_DIR="$(cd $(dirname "$0"); pwd)"
VEEWEE_DIR="$(cd "$SCRIPT_DIR/../../../"; pwd)"
VEEWEE_UID=$(stat -f %u "$VEEWEE_DIR")
VEEWEE_GID=$(stat -f %g "$VEEWEE_DIR")
DEFINITION_DIR="$(cd $SCRIPT_DIR/..; pwd)"

if [ "$2" == "" ]; then
	DEFAULT_ISO_DIR=1
	OLDPWD=$(pwd)
	cd "$SCRIPT_DIR"
	# default to the veewee/iso directory
	if [ ! -d "../../../iso" ]; then
		mkdir "../../../iso"
		chown $VEEWEE_UID:$VEEWEE_GID "../../../iso"
	fi
	OUT_DIR="$(cd $SCRIPT_DIR; cd ../../../iso; pwd)"
	cd "$OLDPWD" # Rest of script depends on being in the working directory if we were passed relative paths
else
	OUT_DIR="$2"
fi

if [ ! -d "$OUT_DIR" ]; then
	msg_status "Destination dir $OUT_DIR doesn't exist, creating.."
	mkdir -p "$OUT_DIR"
fi

if [ -e "$ESD.shadow" ]; then
	msg_status "Removing old shadow file.."
	rm "$ESD.shadow"
fi

MNT_ESD=`/usr/bin/mktemp -d /tmp/veewee-osx-esd.XXXX`
msg_status "Attaching input OS X installer image with shadow file.."
hdiutil attach "$ESD" -mountpoint "$MNT_ESD" -shadow -nobrowse -owners on 
if [ $? -ne 0 ]; then
	[ ! -e "$ESD" ] && msg_error "Could not find $ESD in $(pwd)"
	msg_error "Could not mount $ESD on $MNT_ESD"
	exit 1
fi
if [ ! -e "$MNT_ESD/System/Library/CoreServices/SystemVersion.plist" ]; then
	install_app=$(ls -1 -d "$MNT_ESD/Install OS X"*.app | head -n1)
	if [ -n "$install_app" -a -d "$install_app" ]; then
		# This might be an install .app inside a dmg
		if [ -e "$install_app/Contents/SharedSupport/InstallESD.dmg" ]; then
			TOPLVL_ESD="$ESD"
			TOPLVL_MNT_ESD="$MNT_ESD"
			ESD="$install_app/Contents/SharedSupport/InstallESD.dmg"

			MNT_ESD=`/usr/bin/mktemp -d /tmp/veewee-osx-esd.XXXX`
			msg_status "Found an 'Install OS X *.app' file: $install_app"
			msg_status "Attaching to OS X installer image with shadow file.."
			hdiutil attach "$ESD" -mountpoint "$MNT_ESD" -shadow -nobrowse -owners on 
			if [ $? -ne 0 ]; then
				[ ! -e "$ESD" ] && msg_error "Could not find $ESD in $(pwd)"
				msg_error "Could not mount $ESD on $MNT_ESD"
				exit 1
			fi
			if [ ! -e "$MNT_ESD/System/Library/CoreServices/SystemVersion.plist" ]; then
				msg_error "Can't determine OSX version.  File not found: $MNT_ESD/System/Library/CoreServices/SystemVersion.plist"
				exit 1
			fi
		else
			msg_error "Can't locate an InstallESD.dmg in this source location $install_app!"
		fi
	else
		msg_error "Can't determine OSX version.  File not found: $MNT_ESD/System/Library/CoreServices/SystemVersion.plist"
		hdiutil detach "$MNT_ESD"
		rm "$ESD.shadow"
		rm -rf "$MNT_ESD"
		exit 1
	fi
fi
DMG_OS_VERS=$(/usr/libexec/PlistBuddy -c 'Print :ProductVersion' "$MNT_ESD/System/Library/CoreServices/SystemVersion.plist")
DMG_OS_VERS_MAJOR=$(echo $DMG_OS_VERS | awk -F "." '{print $2}')
DMG_OS_BUILD=$(/usr/libexec/PlistBuddy -c 'Print :ProductBuildVersion' "$MNT_ESD/System/Library/CoreServices/SystemVersion.plist")
OUTPUT_DMG="$OUT_DIR/OSX_InstallESD_${DMG_OS_VERS}_${DMG_OS_BUILD}.dmg"
if [ -e "$OUTPUT_DMG" ]; then
	msg_error "Output file $OUTPUT_DMG already exists! We're not going to overwrite it, exiting.."
	hdiutil detach "$MNT_ESD"
	if [ -n "$TOPLVL_MNT_ESD" ]; then
		hdiutil detach "$TOPLVL_MNT_ESD"
		rm "$TOPLVL_ESD.shadow"
		rm -rf "$TOPLVL_MNT_ESD"
		rm -rf "$MNT_ESD"
	else
		rm "$ESD.shadow"
		rm -rf "$MNT_ESD"
	fi
	exit 1
fi

SUPPORT_DIR="$SCRIPT_DIR/support"

# We need to copy over the AutoPartition.app from System Image Utility, and it needs to match the version of the Guest OS
# 10.7 systems need to get Server Admin Tools here:
# http://support.apple.com/kb/DL1596
# direct link: http://support.apple.com/downloads/DL1596/en_US/ServerAdminTools.dmg
AUTOPART_APP_IN_SIU="System Image Utility.app/Contents/Library/Automator/Create Image.action/Contents/Resources/AutoPartition.app"
OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')
if [ $DMG_OS_VERS_MAJOR -eq 8 ]; then
	if [ $OSX_VERS -eq 7 ]; then
		msg_status "To build Mountain Lion on Lion, we need to extract AutoPartition.app from within the 10.8 installer ESD."
		SIU_TMPDIR=$(/usr/bin/mktemp -d /tmp/siu-108.XXXX)
		msg_status "Expanding flat package.."
		pkgutil --verbose --expand "$MNT_ESD/Packages/Essentials.pkg" "$SIU_TMPDIR/expanded"

		msg_status "Generating BOM.."
		mkbom -s -i "$SUPPORT_DIR/10_8_AP_bomlist" "$SUPPORT_DIR/BOM"

		msg_status "Extracting AutoPartition.app using ditto.."
		ditto --bom "$SUPPORT_DIR/BOM" -x "$SIU_TMPDIR/expanded/Payload" "$SIU_TMPDIR/ditto"
		if [ ! -d "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}" ]; then
			mkdir "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}"
		fi

		msg_status "Copying out AutoPartition.app.."
		cp -R "$SIU_TMPDIR/ditto/System/Library/CoreServices/$AUTOPART_APP_IN_SIU" "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}/"
		msg_status "Removing temporary extracted files.."
		rm -rf "$SIU_TMPDIR"
		rm "$SUPPORT_DIR/BOM"

		AUTOPART_TOOL="$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}/AutoPartition.app"

	elif [ $OSX_VERS -eq 8 ]; then
		AUTOPART_TOOL="/System/Library/CoreServices/$AUTOPART_APP_IN_SIU"
		if [ ! -e "$AUTOPART_TOOL" ]; then
			msg_error "We're on Mountain Lion, and should have System Image Utility available at $AUTOPART_TOOL, but it's not available for some reason."
			exit 1
		fi
		cp -R "$AUTOPART_TOOL" "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}/"
	fi
# on Lion, we first check if Server Admin Tools are already installed..
elif [ $DMG_OS_VERS_MAJOR -eq 7 ]; then
	msg_status "Building OS X 10.${DMG_OS_VERS_MAJOR}, so trying to locate System Image Utility from Server Admin Tools.."
	AUTOPART_TOOL="/Applications/Server/$AUTOPART_APP_IN_SIU"
	# TODO: Sanity-check that this is actually the right version of SIU
	if [ ! -d "$AUTOPART_TOOL" ]; then
		# then we check if _we_ installed them in support/AutoPartition-10.7
		AUTOPART_TOOL="$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}/AutoPartition.app"
		if [ ! -d "$AUTOPART_TOOL" ]; then
			# Lion SAT download
			SAT_URL=http://support.apple.com/downloads/DL1596/en_US/ServerAdminTools.dmg
			
			msg_status "It doesn't seem to be installed and VeeWee hasn't yet cached it in the support dir.."
			msg_status "Attempting download of the Server Admin Tools.."
			SAT_TMPDIR=$(/usr/bin/mktemp -d /tmp/server-admin-tools.XXXX)
			
			curl -L "$SAT_URL" -o "$SAT_TMPDIR/sat.dmg"
			msg_status "Attaching Server Admin Tools.."
			hdiutil attach "$SAT_TMPDIR/sat.dmg" -mountpoint "$SAT_TMPDIR/mnt"

			msg_status "Expanding package.."
			pkgutil --expand "$SAT_TMPDIR/mnt/ServerAdminTools.pkg" "$SAT_TMPDIR/expanded"
			hdiutil detach "$SAT_TMPDIR/mnt"
			mkdir "$SAT_TMPDIR/cpio-extract"

			msg_status "Extracting payload.."
			tar -xz -C "$SAT_TMPDIR/cpio-extract" -f "$SAT_TMPDIR/expanded/ServerAdminTools.pkg/Payload"
			if [ ! -d "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}" ]; then
				mkdir "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}"
			fi

			msg_status "Copying out AutoPartition.app"
			cp -R "$SAT_TMPDIR/cpio-extract/Applications/Server/$AUTOPART_APP_IN_SIU" "$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}/"

			rm -rf "$SAT_TMPDIR"
			# AUTOPART_TOOL="$SUPPORT_DIR/AutoPartition-${DMG_OS_VERS_MAJOR}/AutoPartition.app"
		else msg_status "Found AutoPartition.app at $AUTOPART_TOOL.."
		fi
	fi
elif [ $DMG_OS_VERS_MAJOR -lt 7 ]; then
	msg_error "VeeWee currently doesn't support building guest OS X versions prior to 10.7."
	exit 1
fi

# Build our post-installation pkg that will create a vagrant user and enable ssh
msg_status "Making firstboot installer pkg.."

# payload items
mkdir -p "$SUPPORT_DIR/pkgroot/private/var/db/dslocal/nodes/Default/users"
mkdir -p "$SUPPORT_DIR/pkgroot/private/var/db/shadow/hash"
cp "$SUPPORT_DIR/vagrant.plist" "$SUPPORT_DIR/pkgroot/private/var/db/dslocal/nodes/Default/users/vagrant.plist"
VAGRANT_GUID=$(/usr/libexec/PlistBuddy -c 'Print :generateduid:0' "$SUPPORT_DIR/vagrant.plist")
cp "$SUPPORT_DIR/shadowhash" "$SUPPORT_DIR/pkgroot/private/var/db/shadow/hash/$VAGRANT_GUID"

# postinstall script
mkdir -p "$SUPPORT_DIR/tmp/Scripts"
cp "$SUPPORT_DIR/pkg-postinstall" "$SUPPORT_DIR/tmp/Scripts/postinstall"
# executability should be copied over, warn if we had to chmod again
if [ ! -x "$SUPPORT_DIR/tmp/Scripts/postinstall" ]; then
	msg_status "'postinstall' script was for some reason not executable. Setting it again now, but it should have been already set when copying the definition."
	chmod a+x "$SUPPORT_DIR/tmp/Scripts/postinstall"
fi

# build it
BUILT_PKG="$SUPPORT_DIR/tmp/veewee-config.pkg"
pkgbuild --quiet \
	--root "$SUPPORT_DIR/pkgroot" \
	--scripts "$SUPPORT_DIR/tmp/Scripts" \
	--identifier com.vagrantup.veewee-config \
	--version 0.1 \
	"$BUILT_PKG"
rm -rf "$SUPPORT_DIR/pkgroot"

# Add our auto-setup files: minstallconfig.xml, OSInstall.collection and PartitionInfo.plist
msg_status "Adding automated components.."
mkdir "$MNT_ESD/Packages/Extras"
cp "$SUPPORT_DIR/minstallconfig.xml" "$MNT_ESD/Packages/Extras/"
cp "$SUPPORT_DIR/OSInstall.collection" "$MNT_ESD/Packages/"
cp "$SUPPORT_DIR/PartitionInfo.plist" "$MNT_ESD/Packages/Extras/"
cp -R "$AUTOPART_TOOL" "$MNT_ESD/Packages/Extras/AutoPartition.app"
cp "$BUILT_PKG" "$MNT_ESD/Packages/"
rm -rf "$SUPPORT_DIR/tmp"

msg_status "Unmounting.."
hdiutil detach "$MNT_ESD"

msg_status "Converting to final output file.."
hdiutil convert -format UDZO -o "$OUTPUT_DMG" -shadow "$ESD.shadow" "$ESD"
if [ -z "$TOPLVL_ESD" ]; then
	rm "$ESD.shadow"
	rm -rf "$MNT_ESD"
else
	hdiutil detach "$TOPLVL_MNT_ESD"
	rm "$TOPLVL_ESD.shadow"
	rm -rf "$TOPLVL_MNT_ESD"
	rm -rf "$MNT_ESD"
fi

msg_status "Fixing permissions.."
chown -R $VEEWEE_UID:$VEEWEE_GID \
	"$OUTPUT_DMG" \
	"$SUPPORT_DIR/AutoPartition-10.${DMG_OS_VERS_MAJOR}"

if [ -n "$DEFAULT_ISO_DIR" ]; then
	DEFINITION_FILE="$DEFINITION_DIR/definition.rb"
	msg_status "Setting ISO file in definition "$DEFINITION_FILE".."
	ISO_FILE=$(basename "$OUTPUT_DMG")
	# Explicitly use -e in order to use double quotes around sed command
	sed -i -e "s/%OSX_ISO%/${ISO_FILE}/" "$DEFINITION_FILE"
fi

msg_status "Done."
