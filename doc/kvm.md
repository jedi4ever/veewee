# KVM Provider

NOTE: Virtualbox doesn't like KVM to be enabled

## Prerequisites

To check if your kernel can run kvm :

    # kvm_ok or kvm-ok command (on Ubuntu at least)
    kvm_ok
    # or look for vmx or svm in /proc/cpuinfo
    egrep '^flags.*(vmx|svm)' /proc/cpuinfo

The modules needed are the following : kvm, kvm_intel or kvm-amd.

You need to have at least one storage pool defined in libvirt. You can check all
available storage pools with

    virsh pool-list

If no storage pool is listed, you can create a new storage pool which saves all
VM images in the directory /var/lib/libvirt/images with

    mkdir -p /var/lib/libvirt/images
    cat > /tmp/pool.xml << EOF
    <pool type="dir">
      <name>virtimages</name>
      <target>
        <path>/var/lib/libvirt/images</path>
        <format type='qcow2'/>
      </target>
    </pool>
    EOF
    virsh pool-create /tmp/pool.xml

You need to have at least one network defined. You can check all available
networks with

    virsh net-list

If there is no default network, consult the documentation of your operating
system to find out how to creat it.

If you are using libvirt with a URI different than the default `qemu:///system`,
you need to create a config file for fog.io. If your libvirt endpoint is
accessible at `qemu+ssh://cloud@myhost.com/system` you can create the .fog config
file with

    cat > ~/.fog << EOF
    :default:
      :libvirt_uri: qemu+ssh://cloud@myhost.com/system

## Using VeeWee

List available templates

    veewee kvm templates

Use one of the listed templates to define a new box e.g. with

    veewee kvm define 'My Ubuntu 12.10 box' 'ubuntu-12.10-server-amd64'

Build the box using KVM / Quemu (this will take a while)

    veewee kvm build 'My Ubuntu 12.10 box'

You may want to use the VNC console (e.g. through virt-manager) to monitor /
check the build process.

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
