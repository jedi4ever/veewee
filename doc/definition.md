# Veewee definition

## Creating a definition
A definition is created by 'cloning' a *template*.

To create a definition you use the 'define' subcommand:

    veewee vbox define 'myubuntu' 'ubuntu-10.10-server-amd64'

If you want to use an external repo for the definition you can specify a git-url

    veewee vbox define 'myubuntu' 'git://github.com/jedi4ever/myubuntu'

## Modifying a definition
Definitions are stored under a directory 'definitions' relative to the current directory.

    <currentdir>
    |- <definitions>
    |   |--myubuntu
    |      |-- definition.rb
    |      |-- <preseed.cfg,kickstart.cfg,....>
           |-- base.sh
           |-- ....sh
           |-- ruby.sh
           |-- chef.sh
           |-- puppet.sh
           |-- virtualbox.sh
           |-- ...sh
           |-- cleanup.sh

The file 'definition.rb' contains all the parameters to define the machine to be build:

  - memorysize
  - number of cpus
  - user account and password
  - sudo command
  - shutdown command
  - URL and checksum to download the ISO
  - ....

When a new boots, it will typically fetch it's initial configuration file over http from a preseed.cfg, kickstart, ... file

Once the initial installation is done, veewee will log in to the sytem and starts executing the 'shell files'

The main reason for splitting up the postinstall.sh we used to have, it to make the script parts reusable for different virtualization systems: f.i. no need to install virtualbox guest additions on kvm or vmware fusion.

_Changes between v0.2 -> v0.3_

The 'Veewee::Session.declare' is now deprecated and you should use 'Veewee::Definition.declare'

'Postinstall_files' prefixed with an  _underscore_ are not executed but can be toggled with the --include, --exclude with the <build> command. This allows you to insert different ruby.sh scripts, disable the installation of puppet, etc...

The default user of definitions is now 'veewee' and not 'vagrant'. This is because on other virtualizations like fusion and kvm, there is not relationship with the 'vagrant'. Users 'vagrant' are created by the 'vagrant.sh' script and not by the preseed or kickstart.

_Using ERB in files_

Add '.erb' to your files in a definition and they will get rendered (useful for generting kickstart,postinstall) (thx @mconigilaro)

## Listing existing definitions

    veewee vbox list

## Removing a definition

    veewee vbox undefine 'myubuntu'

## Provider ``vm_options``

Each provider _can_ take options that are specific to them ; more detail will
be available in each provider documentation but let's have a quick overview.

    Veewee::Definition.declare( {
        :cpu_count => '1', :memory_size=> '256', 
        :disk_size => '10140', :disk_format => 'VDI', :disk_variant => 'Standard',
        # […]
        :postinstall_files => [ "postinstall.sh"],:postinstall_timeout => "10000"
        :kvm => { :vm_options => ['network_type' => 'bridge', 'network_bridge_name' => 'brlxc0']}
        :virtualbox => { :vm_options => [ 'pae' => 'on', 'ioapic' => 'one'] }
     }
    )

This box will have ``pae`` and ``ioapic`` enabled on virtualbox, and will use
the ``brlxc0`` bridge on with kvm (on libvirt).
