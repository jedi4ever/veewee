# TODO

## Ideas

* Integrate Veewee with your CI build to create baseboxes on a daily basis
* Use of pre_postinstall_file in `definition.rb` _by whren - 2012-04-12_. See [use of pre_postinstall_file in definition.rb](https://github.com/whren/veewee/wiki/use-of-pre_postinstall_file-in-definition.rb)]


## Requirements

    virtualbox ->

    kvm -> ruby-libvirt gem
    v0.8.3 or higher
    require libvirt 0.8+ version
    have a default dir pool installed
    permissions to write create new volumes

    vmfusion -> VMWare fusion installed
    Tested on VMWare fusion 0.3.x


## Changes to Definitions

Virtualbox options ioapic, pae are now moved to :virtualbox => { vm_options => [ :ioapic => 'on' ]} ;
Now you can pass all options you have to virtualbox


## Use as a library

    ostype_id (not used for all providers)

    Rakefile contains check iso
    Rakefile contains test
    Rakefile contains real_test


## Templates

    check for .veewee_version or .vmfusion_version to see for which provider we are building this
    include/exclude can do this
    default user becomes veewee, vagrant.sh will create the vagrant user if used under vagrant
    uploading vmware.iso
    uploading virtualbox.iso


## Validation

    veewee.feature (depending on virtualbox, vagrant)
    no more ssh_steps
    uses @tags per provider

    # veewee vmfusion export ova
    # vagrant basebox export box


## New options

    --postinstall-include/exclude
    --auto (download yes)
    --force also for export
    --debug (debug output)

    ostypes are now synchronized accross kvm


## More Todos

    veewee steps (username,password, + VEEWEE env variables)
    validate vms - + features selection
    check libvirt version
    windows test
    validation of checks (also - include/exclude)
    check execs with exit code
    multinetwork card
    dkms for kernel installs
