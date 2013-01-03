NOTE:Virtualbox doesn't like KVM to be enabled

## Prerequires

To check if you're kernel can run kvm :

    # kvm_ok or kvm-ok command (on Ubuntu at least)
    kvm_ok
    # or look for vmx or svm in /proc/cpuinfo
    egrep '^flags.*(vmx|svm)' /proc/cpuinfo

The modules needed are the following : kvm, kvm_intel or kvm-amd.

## Define a new box

The workflow to create a box is almost the same as with the Virtualbox
provider (and others).

## Options

There is currently few options supported :

1. **network_type**: the type of network used by this box on libvirt. It could
   be either _network_ (for using the default network) or _bridge_.
2. **network_bridge_name**: the name of the bridge. It is used just in case
   **network_type** is set to _bridge_.
3. **pool_name**: the _storage_ pool name to be used when creating the box. If
   not specified, the default one is used.

## Notes

Remove modules:

    rmmod kvm_intel
    rmmod kvm
