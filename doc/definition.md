# Veewee definition

## Creating a definition
A definition is create be 'cloning' a *template*.

To create a definition you use the 'define' subcommand:

    veewee vbox define 'myubuntu' 'ubuntu-10.10-server-amd64'

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


## Listing existing definitions

    veewee vbox list

## Removing a definition

    veewee vbox undefine 'myubuntu'
