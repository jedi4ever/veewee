The veewee vSphere provider adds the capability to create base boxes/VMs on VMware ESXi/vSphere and vCenter servers. Because this capability leverages a centralized hypervisor (rather than a local hypervisor on the machien running the veewee command), there are some considerations when building a machine that are unique to this provider.

vCenter server support is still experimental pending further tests with more advance vCenter features

## Credentials

vSphere/vCenter require a users to authenticate actions the remote server in order to perform management actions. User credentials can be specified in 3 ways, in order of precedence:

1. Use the -h (i.e., vsphere_server), -u (i.e., vsphere_user), and -p (i.e., vsphere_password) options with each `veewee vsphere` command
2. Set the `VEEWEE_VSPHERE_AUTHFILE` environment variable to the path of a YAML files with the vSphere server hostname and credentials
3. The vSphere server and user can be provided by either method above, and veewee vsphere provider will prompt the user for the password.

Note, a `VEEWEE_VSPHERE_AUTHFILE` YAML file contains credentials to login to a given vSphere/vCenter server. It is the responsibility of the user to ensure this file has appropriate access controls applied to ensure proper security compliance.

### YAML configuration format

```yaml
---
vsphere_server: vcenter.example.com
vsphere_user: vsphere-user
vsphere_password: vsphere-password
```

## Datacenter Configuration

The vSphere datacenter targeted can be specified by using the `:datacenter` vm_option

Logic should look for the datacenter in the following order:

* If datacenter is specified as vm option in definition and it exists, use that datacenter
* If only one datacenter exists and no datacenter is specified, use that datacenter

All other conditions result in errors.

Note: although ESXi servers do not show a concept of a datacenter in the vSphere Client, the vSphere API creates a default datacenter "ha-datacenter" to provide a consistent API.

## Compute Resource Configuration

The compute resource targeted can be specified by using the `:compute_resource` vm_option

* In the case of vSphere ESXi, there is one compute resource that encapsulates the ESXi server
* In the case of vCenter, there are one or more compute resources that represent a single ESXi server or a cluster

If multiple Compute Resources exist and a name is not provided, an error is raise


## Networking support

vSphere does not have built in support concepts like a NAT network configuration within the hypervisor itself. This means that when creating a virtual machine, a veewee vSphere user needs to have the appropriate networking capability in place prior to issuing vSphere build commands. In addition, there are special steps that must be completed within definition.rb and kickstart or preseed.cfg files to ensure network support works as expected.

### Virtual Network

Each vSphere/vCenter enviornment has a series of virtual networks that can be added to an individual virtual machine. Veewee must specify the virtual network when building a vSphere VM to make sure the remaining commands can be executed as expected. The virtual network can be set in 3 ways, listed below in the order of precedence:

1. `--net` option provided with the `veewee vsphere build` command
2. Contents of the definition.rb vsphere properties `:vsphere => { :vm_options => { :network => "VM Network" } }`
3. If no name provided and only one network exists, choose that network

Along with the above virtual network definition, the following assumptions are made about the state of the network:

* The network includes a DHCP server that can provide a new VM with an IP address to communicate on the network
* The host issuing the veewee command has a route to the VM after its created on the virtual network

### Veewee Host IP

Because we cannot assume anything about the network topology between the veewee host and the virtual network attached to a VMware VM build using the vSphere provider, the IP address used to serve the kickstart or preseed.cfg file must be specified as part of the definition.rb file. This can be configured using the following:

    :vsphere => { :kickstart_ip => "192.168.0.1" }

    veewee will raise an error if this configuration is not complete.

## Data Location

vSphere defines storage for VMs and files as a series of datastores within a given server or cluster. The vSphere provider must specify a datastore to build a given VM in. The datastore can be set in 3 ways, listed below in the order of precedence:

1. `--ds` option provided with the `veewee vsphere build` command
2. Contents of the definition.rb vsphere properties `:vsphere => { :vm_options => { :datastore => "datastore" } }`
3. If no name provided and only one datastore exists, choose that datastore

Note, the datastore location chosen is used for both creating the VM and its associated files, and also for uploading ISO files used to build the VM.

## VNC Dependencies

The vSphere provider, like other veewee providers, depends on VNC to configure the guest OS being built. On ESXi 5.x hosts, the internal firewall is disabled by default. The following gist contains the instructions for ESXi 5.1: https://gist.github.com/4670943.

TODO Embed gist information

## VMware Tools

In order to complete postinstall.sh scripts, veewee has to be able to determine the created VMs IP address after OS installation is complete. vSphere/vCenter do not have a method to retrieve this information withou the VMware Tools--the VMware equivalent of VirtualBox Guest Additions--installed on the guest OS. Therefore, the kickstart or preseed.cfg files used to automated the OS installation must be modified in order to install VMware Tools prior to the OS installation completing. This will allow post installation actions to execute as expected.

### RHEL/CentOS Instructions

Follow the instructions from VMware for installing VMware tools on a RHEL platform as seen at the following link: http://www.vmware.com/download/packages.html.

### Ubuntu Instructions

On Ubuntu distributions, VMware tools can be added by installing the open-vm-tools from the multiverse repository inside the preseed.cfg file. For example:

    d-i pkgsel/include string openssh-server open-vm-tools

    There can be only one instance of this within a preseed.cfg file, so ensure that if you add open-vm-tools to the existing command as provided.

## External tool pre-requisites

The following tools are needed to support the execution of the vSphere provider:

* curl - used to upload files to a vSphere datastore (specifically to support ISO uploads). This will hopefully be corrected in later revisions to replace curl with a native ruby solution
* ovftool - used for the `veewee vsphere export` command to export a VM from the vSphere/vCenter server to an ova file

The veewee vSphere provider assumes both of these tools are in the user's path.

## Command Timing

Working with a remote server increases the likelihood that veewee processes that depend on waits or delays to execute a given command will fail leaving veewee and the guest VM being built in an unstable state. Users should consider increasing timeouts if issues appear where steps are out of sequence.
