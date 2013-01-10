# KVM Provider

NOTE: Virtualbox doesn't like KVM to be enabled

## Prerequisites

Depending on your operating system you may need to install packages for kvm,
qemu and libvirt.

To check if your kernel can run kvm :

    # kvm_ok or kvm-ok command (on Ubuntu at least)
    kvm_ok
    # or look for vmx or svm in /proc/cpuinfo
    egrep '^flags.*(vmx|svm)' /proc/cpuinfo

The kernel modules needed are the following : kvm, kvm_intel or kvm-amd.

### Storage Pool

You need to have at least one storage pool defined in libvirt where your VM
images will be stored. You can check all available storage pools with

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

### Network

You need to have at least one network defined. You can check all available
networks with

    virsh net-list

If there is no network, consult the documentation of your operating
system to find out how to creat it. More information can also be found in the
[libvirt documentation](http://libvirt.org/formatdomain.html#elementsNICS).

If you are using libvirt with a URI different than the default `qemu:///system`,
you need to create a config file for fog.io. If your libvirt endpoint is
accessible at `qemu+ssh://cloud@myhost.com/system` you can create the .fog config
file with

    cat > ~/.fog << EOF
    :default:
      :libvirt_uri: qemu+ssh://cloud@myhost.com/system
    EOF

For more information have a look at the
[libvirt documentation](http://libvirt.org/drvqemu.html#uris).

## Using VeeWee

You can always get help by using the the built in help with every command.
e.g. for the build command use

    veewee kvm help build

List available templates

    veewee kvm templates

Use one of the listed templates to define a new box e.g. with

    veewee kvm define 'My Ubuntu 12.10 box' 'ubuntu-12.10-server-amd64'

Build the box using KVM / Quemu (this will take a while)

    veewee kvm build 'My Ubuntu 12.10 box'

You can specify the name of the storage pool and the network to be used when
building a VM. Use the options`--pool-name` and `--network-name` with the built
command:

    veewee kvm build 'My Ubuntu 12.10 box' --pool-name virtimages --network-name default