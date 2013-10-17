# VirtualBox VM Provider

To interact with [VirtualBox](http://www.virtualbox.org/), Veewee
executes shell-commands through the 'VboxManage' command. The
`virtualbox` gem library proved to be less stable.

## Interacting with Guest Machine
To simulate the typing, Veewee uses the `VBoxManage` command:

`$ VBoxManage controlvm 'myubuntu' keyboardputscancode <keycode>`

[Scancodes](http://www.win.tue.nl/~aeb/linux/kbd/scancodes-1.html) are
injected directly
from the keyboard buffer with this command.  Because this buffer is
small, Veewee can't type fast(er). This is why you'll notice a delay
before Veewee types the commands. Speeding it up would make the keyboard
buffer lose keystrokes.

## VirtualBox OS_Types
VirtualBox supports a wide variety of Guest Operating Systems.  The
table below is a partial list of a few of the popular `os_types`.  *For
a complete list* run the `virtualbox` command: `VBoxManage list ostypes`

OS_TYPE_ID     | DESCRIPTION
-------------- | -------------------
ArchLinux_64   | Arch Linux (64 bit)
ArchLinux      | Arch Linux
Debian_64      | Debian (64 bit)
Debian         | Debian
Fedora_64      | Fedora (64 bit)
Fedora         | Fedora
FreeBSD_64     | FreeBSD (64 bit)
FreeBSD        | FreeBSD
Gentoo_64      | Gentoo (64 bit)
Gentoo         | Gentoo
MacOS_64       | Mac OS X (64 bit)
MacOS          | Mac OS X
OpenSUSE_64    | openSUSE (64 bit)
Other          | Other/Unknown (32bit)
RedHat_64      | CentOS (64 bit)
RedHat         | CentOS
RedHat_64      | Red Hat (64 bit)
RedHat         | Red Hat
Ubuntu_64      | Ubuntu (64 bit)
Ubuntu         | Ubuntu
Windows2012_64 | Windows 2012 (64 bit)
Windows81_64   | Windows 8.1 (64 bit)
Windows81      | Windows 8.1
Windows8       | Windows 8


## Guest Machine Settings
`Virtualbox` creates *default VM settings* for a new Guest Machine
based on the internal `os_type`.  For example, 64bit machines are setup
with IO_APIC on so that guest machines can utilize multiple CPU's. 32bit
Machines have IO_APIC off by default, even though modern 32-bit systems
have [good support for SMP](http://en.wikipedia.org/wiki/Intel_APIC_Architecture#Problems).
Therefore this, and other settings can be overridden within
the `definion.rb` file, by using an array similar to:

    :virtualbox => {
      :vm_options => [
        # Some example settings
        'audio' => 'null',              # Enable Audio by setting host to null driver
        'audiocontroller' => 'hda',     # Use simulated Intel HD audio
        'ioapic' => 'on',               # APIC is necessary for symmetric multiprocessor (SMP) support
        'rtcuseutc' => 'on',            # UTC internal time
        'usb' => 'on',
        'mouse' => 'usbtablet',         # Enable absolute pointing device
        'usbwebcam' => 'on',
        'accelerate3d' => 'on',         # Necessary for X to start the Unity desktop in Ubuntu 12.10+ -- Useful for 12.04, although can slow the VM if host hardware lacks good 3D support
        'clipboard' => 'bidirectional'  # Useful for clipboard sharing between host & guest
        'nonrotational' => 'on'         # Useful for guest OS's like Windows, so disk utilities aren't run

        # A Full list of settings can be found here: http://virtualbox.org/manual/ch08.html#idp51057568
        # Or generated based on the current settings of a virtualbox guest, such a machine named: myubuntu
        # VBoxManage showvminfo --machinereadable 'myubuntu'
        ]
      }
